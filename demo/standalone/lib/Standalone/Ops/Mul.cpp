#include "Standalone/IR/Standalone.h"
#include "Standalone/Utils/BaseUtils.h"

using namespace mlir;
using namespace mlir::standalone;

LogicalResult MulOp::inferReturnTypeComponents(
    MLIRContext *context, ::std::optional<Location> location,
    ValueShapeRange operands, DictionaryAttr attributes,
    OpaqueProperties properties, RegionRange regions,
    SmallVectorImpl<ShapedTypeComponents> &inferredReturnShapes) {
    // mul op's output shape only depend on input1 and input2, not on shift
    ValueShapeRange twoInputs = operands.drop_back();
    llvm::SmallVector<int64_t> outShape;
    if (resolveBroadcastShape(twoInputs, outShape).failed()) {
      inferredReturnShapes.push_back(ShapedTypeComponents());
    } else {
      inferredReturnShapes.push_back(ShapedTypeComponents(outShape));
    }
    return success();
  }
  
LogicalResult MulOp::verify() {

    const Value output = getOutput();
    auto resElemType = getElementTypeOrSelf(output);
  
    // Verify if the element type among operands and result match tosa
    // specification.
    if (auto resIntType = dyn_cast<IntegerType>(resElemType)) {
      IntegerType lhsIntType =
          dyn_cast<IntegerType>(getElementTypeOrSelf(getInput1()));
      IntegerType rhsIntType =
          dyn_cast<IntegerType>(getElementTypeOrSelf(getInput2()));
      if (!lhsIntType || !rhsIntType || lhsIntType != rhsIntType)
        return emitOpError("requires the same element type for all operands");
  
      // Though the spec requires the element type of result to be i32, a more
      // relaxed way is provided at dialect level for easier cooperating with
      // other dialects.
      if (lhsIntType.getWidth() > resIntType.getWidth())
        return emitOpError("invalid data type size for operands or result");
  
    } else {
      // For other supported type, the spec requires requires the same element
      // type for all operands (excludes `shift` operand) and results.
      for (int i = 0; i < 2; ++i) {
        if (getElementTypeOrSelf(getOperand(i)) != resElemType)
          return emitOpError(
              "requires the same element type for all operands and results");
      }
  
      // // verify shift has value 0 for non-integer types
      // ElementsAttr shift_elem;
      // if (matchPattern(getShift(), m_Constant(&shift_elem))) {
      //   int32_t shift = shift_elem.getValues<IntegerAttr>()[0].getInt();
      //   if (shift != 0) {
      //     return emitOpError() << "require shift to be 0 for float type";
      //   }
      // }
    }
  
    // Verify the op has same ranks for all main operands (excludes extra operands
    // such as shift of mul op, so this is the only difference with the built-in
    // `SameOperandsAndResultRank` trait) and results types, if known.
    TypeRange operandTypes = getOperandTypes();
    ShapedType aType = cast<ShapedType>(operandTypes[0]);
    ShapedType bType = cast<ShapedType>(operandTypes[1]);
  
    const bool aHasRank = aType.hasRank();
    const bool bHasRank = bType.hasRank();
    if (aHasRank && bHasRank) {
      const int64_t aRank = aType.getRank();
      const int64_t bRank = bType.getRank();
      if (aRank != bRank)
        return emitOpError("a and b operands don't have matching ranks, got ")
              << aRank << " and " << bRank;
  
      // check for broadcast compatible shapes
      SmallVector<int64_t> resultShape;
      if (!mlir::OpTrait::util::getBroadcastedShape(
              aType.getShape(), bType.getShape(), resultShape))
        return emitOpError("a and b operands don't have broadcast-compatible "
                          "shapes, got ")
              << aType << " and " << bType;
    }
  
    ShapedType resultType = cast<ShapedType>(output.getType());
    if (!resultType.hasRank())
      return success();
  
    const int64_t resultRank = resultType.getRank();
    if (aHasRank && resultRank != aType.getRank())
      return emitOpError("result type has different rank than a, got ")
            << resultRank << " vs " << aType.getRank();
    if (bHasRank && resultRank != bType.getRank())
      return emitOpError("result type has different rank than b, got ")
            << resultRank << " vs " << bType.getRank();
  
    return success();
  
  }
  
  // calculate lhs * rhs >> shift according to TOSA Spec
  // return nullopt if result is not in range of int32_t when shift > 0
  std::optional<APInt> mulInt(APInt lhs, APInt rhs, int32_t shift,
                              unsigned bitwidth) {
    APInt result = lhs.sext(64) * rhs.sext(64);
  
    if (shift > 0) {
      auto round = APInt(64, 1) << (shift - 1);
      result += round;
      result.ashrInPlace(shift);
      // REQUIRE(product >= minimum_s<i32_t>() && product <= maximum_s<i32_t>())
      if (!(result.getSExtValue() >= INT32_MIN &&
            result.getSExtValue() <= INT32_MAX)) {
        // REQUIRE failed
        return std::nullopt;
      }
    }
  
    return result.trunc(bitwidth);
  }
  
  DenseElementsAttr mulBinaryFolder(DenseElementsAttr lhs, DenseElementsAttr rhs,
                                    RankedTensorType ty, int32_t shift) {
    if (rhs && lhs && rhs.isSplat() && lhs.isSplat()) {
      if (llvm::isa<IntegerType>(ty.getElementType())) {
        APInt l = lhs.getSplatValue<APInt>();
        APInt r = rhs.getSplatValue<APInt>();
  
        if (shift == 0) {
          return DenseElementsAttr::get(ty, l * r);
        }
  
        auto bitwidth = ty.getElementType().getIntOrFloatBitWidth();
        const std::optional<APInt> result = mulInt(l, r, shift, bitwidth);
        if (!result)
          return {};
        return DenseElementsAttr::get(ty, result.value());
      }
  
      if (llvm::isa<FloatType>(ty.getElementType())) {
        APFloat l = lhs.getSplatValue<APFloat>();
        APFloat r = rhs.getSplatValue<APFloat>();
        APFloat result = l * r;
        return DenseElementsAttr::get(ty, result);
      }
    }
  
    return {};
  }
  
  OpFoldResult MulOp::fold(FoldAdaptor adaptor) {
    auto lhs = getInput1();
    auto rhs = getInput2();
    auto lhsTy = llvm::dyn_cast<RankedTensorType>(lhs.getType());
    auto rhsTy = llvm::dyn_cast<RankedTensorType>(rhs.getType());
    auto resultTy = llvm::dyn_cast<RankedTensorType>(getType());
    if (!lhsTy || !rhsTy || !resultTy)
      return {};
    
    auto resultETy = resultTy.getElementType();
    auto lhsAttr =
        llvm::dyn_cast_if_present<DenseElementsAttr>(adaptor.getInput1());
    auto rhsAttr =
        llvm::dyn_cast_if_present<DenseElementsAttr>(adaptor.getInput2());
  
    // Result right shift on i32_t data type only. For simplification, synthesize
    // a zero shift for other data type.
    int32_t shift = 0;
    // if (resultETy.isInteger(32)) {
    //   ElementsAttr shift_elem;
    //   if (getShift().getImpl()) {
    //     if (!matchPattern(getShift(), m_Constant(&shift_elem)))
    //       // cannot be folded when the shift value is unknown.
    //       return {};
    //     shift = shift_elem.getValues<IntegerAttr>()[0].getInt();
    //   }
    // }
  
    if (rhsTy == resultTy) {
      if (isSplatZero(resultETy, lhsAttr) && resultTy.hasStaticShape())
        // constant values can only be resized if resulting type is static
        return lhsAttr.resizeSplat(resultTy);
      if (isSplatOne(resultETy, lhsAttr, shift))
        return rhs;
    }
    if (lhsTy == resultTy) {
      if (isSplatZero(resultETy, rhsAttr) && resultTy.hasStaticShape())
        return rhsAttr.resizeSplat(resultTy);
      if (isSplatOne(resultETy, rhsAttr, shift))
        return lhs;
    }
  
    return mulBinaryFolder(lhsAttr, rhsAttr, resultTy, shift);
  }