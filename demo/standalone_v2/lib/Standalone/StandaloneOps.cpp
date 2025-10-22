//===- StandaloneOps.cpp - Standalone dialect ops ---------------*- C++ -*-===//
//
// This file is licensed under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "Standalone/StandaloneOps.h"
#include "Standalone/StandaloneDialect.h"
#include "Standalone/StandaloneTypes.h"

#define GET_OP_CLASSES
#include "Standalone/StandaloneOps.cpp.inc"

using namespace mlir;

//===----------------------------------------------------------------------===//
// TOSA Shape and Shape Operators Helper functions.
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
// Standalone operation validation includes.
//===----------------------------------------------------------------------===//

namespace mlir {

    namespace OpTrait {
    namespace standalone {
    
    LogicalResult verifyStandaloneResolvableShapeOperands(Operation *op);
    /// This class verifies that tosa shape operands are compile time resolvable
    template <typename ConcreteType>
    class StandaloneResolvableShapeOperands
        : public TraitBase<ConcreteType, StandaloneResolvableShapeOperands> {
    public:
        static LogicalResult verifyTrait(Operation *op) {
            return verifyStandaloneResolvableShapeOperands(op);
        }
    };
    
    LogicalResult verifyStandaloneShapeOperator(Operation *op);
    /// This class indicates that op operates on tosa shape types
    template <typename ConcreteType>
    class StandaloneShapeOperator : public TraitBase<ConcreteType, StandaloneShapeOperator> {
    public:
      static LogicalResult verifyTrait(Operation *op) {
        return verifyStandaloneShapeOperator(op);
      }
    };
    
} // namespace Standalone
} // namespace OpTrait
} // namespace mlir

LogicalResult mlir::OpTrait::standalone::verifyStandaloneResolvableShapeOperands(Operation *op) {
    for (auto v : op->getOperands()) {
        if (mlir::isa<::mlir::standalone::shapeType>(v.getType())) {
            Operation *definingOp = v.getDefiningOp();
            if (!definingOp || !definingOp->hasTrait<StandaloneShapeOperator>()) {
                return op->emitOpError("shape operand is not compile time resolvable");
            }
        }
    }
    return success();
}

LogicalResult mlir::OpTrait::standalone::verifyStandaloneShapeOperator(Operation *op) {
    for (auto type : op->getOperandTypes()) {
        if (!mlir::isa<mlir::standalone::shapeType>(type)) {
            return op->emitOpError("must have operands with standalone shape type");
        }
    }
    for (auto type : op->getResultTypes()) {
        if (!mlir::isa<mlir::standalone::shapeType>(type)) {
            return op->emitOpError("must have result with standalone shape type");
        }
    }
    return success();
}

//===----------------------------------------------------------------------===//
// Tosa dialect initialization.
//===----------------------------------------------------------------------===//

// TODO
Operation *standalone::StandaloneDialect::materializeConstant(OpBuilder &builder, Attribute value,
  Type type, Location loc) {
  // Tosa dialect constants only support ElementsAttr unlike standard dialect
  // constant which supports all attributes.
  // if (llvm::isa<shapeType>(type) && llvm::isa<DenseIntElementsAttr>(value)) {
  //   return tosa::ConstShapeOp::create(builder, loc, type,
  //     llvm::cast<DenseIntElementsAttr>(value));
  // }
  if (llvm::isa<ElementsAttr>(value))
    return standalone::ConstOp::create(builder, loc, type,
        llvm::cast<ElementsAttr>(value));
  return nullptr;
}


//===----------------------------------------------------------------------===//
// TOSA Operator Return Type Inference.
//===----------------------------------------------------------------------===//

static LogicalResult resolveBroadcastShape(const ValueShapeRange &operands,
                                           SmallVector<int64_t> &outShape) {
  int64_t outRank = 0;
  for (int i = 0, e = operands.size(); i != e; ++i) {
    auto shape = operands.getShape(i);
    if (!shape.hasRank()) {
      // TODO(jennik): Update function to have better case handling for
      // invalid operands and for ranked tensors.
      return failure();
    }
    outRank = std::max<int64_t>(outRank, shape.getRank());
  }

  outShape.resize(outRank, 1);

  for (int i = 0, e = operands.size(); i != e; ++i) {
    auto shape = operands.getShape(i);
    auto rankDiff = outShape.size() - shape.getRank();

    for (size_t i = 0, e = shape.getRank(); i < e; ++i) {
      auto dim1 = outShape[i + rankDiff];
      auto dim2 = shape.getDimSize(i);
      auto resolvedDim = dim1;

      if (dim1 == 1) {
        resolvedDim = dim2;
      } else if (dim2 == 1) {
        resolvedDim = dim1;
      } else if (dim1 != dim2) {
        return failure();
      }
      outShape[i + rankDiff] = resolvedDim;
    }
  }

  return success();
}

static LogicalResult NAryInferReturnTypes(
    const ValueShapeRange &operands,
    SmallVectorImpl<ShapedTypeComponents> &inferredReturnShapes) {
  llvm::SmallVector<int64_t> outShape;
  if (resolveBroadcastShape(operands, outShape).failed()) {
    inferredReturnShapes.push_back(ShapedTypeComponents());
  } else {
    inferredReturnShapes.push_back(ShapedTypeComponents(outShape));
  }
  return success();
}

// #define NARY_SHAPE_INFER(OP)  
// LogicalResult OP::inferReturnTypeComponents(                                 \
//     MLIRContext *context, ::std::optional<Location> location,                \
//     ValueShapeRange operands, DictionaryAttr attributes,                     \
//     OpaqueProperties properties, RegionRange regions,                        \
//     SmallVectorImpl<ShapedTypeComponents> &inferredReturnShapes) {           \
//   return NAryInferReturnTypes(operands, inferredReturnShapes);               \
// }

// NARY_SHAPE_INFER(standalone::AddOp)


LogicalResult standalone::AddOp::inferReturnTypeComponents(                                 \
    MLIRContext *context, ::std::optional<Location> location,                \
    ValueShapeRange operands, DictionaryAttr attributes,                     \
    OpaqueProperties properties, RegionRange regions,                        \
    SmallVectorImpl<ShapedTypeComponents> &inferredReturnShapes) {           \
  return NAryInferReturnTypes(operands, inferredReturnShapes);               \
}


//===----------------------------------------------------------------------===//
// Operator Folders.
//===----------------------------------------------------------------------===//


template <typename IntFolder, typename FloatFolder>
DenseElementsAttr binaryFolder(DenseElementsAttr lhs, DenseElementsAttr rhs,
                               RankedTensorType returnTy) {
  if (rhs && lhs && rhs.isSplat() && lhs.isSplat()) {
    auto lETy = llvm::cast<ShapedType>(lhs.getType()).getElementType();
    auto rETy = llvm::cast<ShapedType>(rhs.getType()).getElementType();
    if (lETy != rETy)
      return {};

    if (llvm::isa<IntegerType>(lETy)) {
      APInt l = lhs.getSplatValue<APInt>();
      APInt r = rhs.getSplatValue<APInt>();
      auto result = IntFolder()(l, r);
      return DenseElementsAttr::get(returnTy, result);
    }

    if (llvm::isa<FloatType>(lETy)) {
      APFloat l = lhs.getSplatValue<APFloat>();
      APFloat r = rhs.getSplatValue<APFloat>();
      auto result = FloatFolder()(l, r);
      return DenseElementsAttr::get(returnTy, result);
    }
  }

  return {};
}

static bool isSplatZero(Type elemType, DenseElementsAttr val) {
  if (llvm::isa<FloatType>(elemType))
    return val && val.isSplat() && val.getSplatValue<APFloat>().isZero();
  if (llvm::isa<IntegerType>(elemType))
    return val && val.isSplat() && val.getSplatValue<APInt>().isZero();
  return false;
}

static bool isSplatOne(Type elemType, DenseElementsAttr val, int64_t shift) {
  if (llvm::isa<FloatType>(elemType))
    return val && val.isSplat() &&
           val.getSplatValue<APFloat>().isExactlyValue(1.0);
  if (llvm::isa<IntegerType>(elemType)) {
    const int64_t shifted = 1LL << shift;
    return val && val.isSplat() &&
           val.getSplatValue<APInt>().getSExtValue() == shifted;
  }
  return false;
}



OpFoldResult standalone::AddOp::fold(FoldAdaptor adaptor) {
  auto lhsTy = llvm::dyn_cast<RankedTensorType>(getInput1().getType());
  auto rhsTy = llvm::dyn_cast<RankedTensorType>(getInput2().getType());
  auto resultTy = llvm::dyn_cast<RankedTensorType>(getType());
  if (!lhsTy || !rhsTy || !resultTy)
      return {};

  // Cannot create an ElementsAttr from non-int/float/index types
  if (!lhsTy.getElementType().isIntOrIndexOrFloat() ||
      !rhsTy.getElementType().isIntOrIndexOrFloat())
      return {};

  auto resultETy = resultTy.getElementType();
  auto lhsAttr =
      llvm::dyn_cast_if_present<DenseElementsAttr>(adaptor.getInput1());
  auto rhsAttr =
      llvm::dyn_cast_if_present<DenseElementsAttr>(adaptor.getInput2());

  if (lhsTy == resultTy && isSplatZero(resultETy, rhsAttr))
      return getInput1();
  if (rhsTy == resultTy && isSplatZero(resultETy, lhsAttr))
      return getInput2();

  if (!lhsAttr || !rhsAttr)
      return {};

  return binaryFolder<std::plus<APInt>, std::plus<APFloat>>(lhsAttr, rhsAttr,
                                                              resultTy);
}

OpFoldResult standalone::ConstOp::fold(FoldAdaptor adaptor) { return getValuesAttr(); }

LogicalResult standalone::ConstOp::verify() {

  auto attrType = llvm::dyn_cast<TensorType>(getValuesAttr().getType());
  auto outputType = llvm::dyn_cast<TensorType>(getOutput().getType());

  if (!attrType || !outputType) {
    emitOpError("expected tensors for attr/result type");
    return failure();
  }

  // if (auto result = llvm::dyn_cast<mlir::quant::QuantizedType>(
  //         outputType.getElementType())) {
  //   if (result.getStorageType() == attrType.getElementType())
  //     return success();
  // }

  if (attrType.getElementType() != outputType.getElementType()) {
    emitOpError("expected same attr/result element types");
    return failure();
  }

  return success();
}


LogicalResult standalone::MulOp::inferReturnTypeComponents(
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

LogicalResult standalone::MulOp::verify() {

  return success();

  #if 0
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

    // verify shift has value 0 for non-integer types
    ElementsAttr shift_elem;
    if (matchPattern(getShift(), m_Constant(&shift_elem))) {
      int32_t shift = shift_elem.getValues<IntegerAttr>()[0].getInt();
      if (shift != 0) {
        return emitOpError() << "require shift to be 0 for float type";
      }
    }
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
#endif 
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

OpFoldResult standalone::MulOp::fold(FoldAdaptor adaptor) {
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