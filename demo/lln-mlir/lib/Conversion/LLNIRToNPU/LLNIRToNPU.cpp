
#include "mlir/Dialect/Arith/IR/Arith.h"
#include "mlir/Dialect/Linalg/IR/Linalg.h"
#include "mlir/Dialect/Math/IR/Math.h"
#include "mlir/Dialect/Tensor/IR/Tensor.h"
#include "mlir/Dialect/Tosa/IR/TosaOps.h"
#include "mlir/Dialect/Tosa/Utils/ConversionUtils.h"
#include "mlir/Dialect/Utils/ReshapeOpsUtils.h"
#include "mlir/IR/PatternMatch.h"
#include "mlir/Transforms/DialectConversion.h"

#include "llnmlir/Conversion/LLNIRToNPU/LLNIRToNPU.h"

#include "llnmlir/Dialect/LLNIR/IR/LLNIR.h"

using namespace mlir;
using namespace mlir::llnir;


void mlir::llnir::populateLLNIRTypeConversion(TypeConverter &converter) {
    // converter.addConversion([&](Type type) -> std::optional<Type> {
    //   if (type.isUnsignedInteger()) {
    //     return IntegerType::get(type.getContext(), type.getIntOrFloatBitWidth(),
    //                             IntegerType::SignednessSemantics::Signless);
    //   }
    //   return type;
    // });
    converter.addConversion([&](TensorType type) -> std::optional<Type> {
      auto converted = converter.convertType(type.getElementType());
      if (!converted)
        return {};
      return type.clone(converted);
    });
    converter.addSourceMaterialization([&](OpBuilder &builder, Type resultType,
                                           ValueRange inputs,
                                           Location loc) -> Value {
      if (inputs.size() != 1)
        return Value();
  
      return UnrealizedConversionCastOp::create(builder, loc, resultType, inputs)
          .getResult(0);
    });
    converter.addTargetMaterialization([&](OpBuilder &builder, Type resultType,
                                           ValueRange inputs,
                                           Location loc) -> Value {
      if (inputs.size() != 1)
        return Value();
  
      return UnrealizedConversionCastOp::create(builder, loc, resultType, inputs)
          .getResult(0);
    });
}

  
SmallVector<Value> condenseValues(const SmallVector<Value> &values) {
  SmallVector<Value> condensedValues;
  for (auto value : values)
    if (value)
      condensedValues.push_back(value);
  return condensedValues;
}

class MatMulConverter : public OpConversionPattern<llnir::MatMulOp> {
public:
    using OpConversionPattern<llnir::MatMulOp>::OpConversionPattern;
    LogicalResult
    matchAndRewrite(llnir::MatMulOp op, OpAdaptor adaptor,
                    ConversionPatternRewriter &rewriter) const final {

        Location loc = op.getLoc();
        
        auto outputTy = cast<ShapedType>(op.getType());
        auto outputElementTy = outputTy.getElementType();

        SmallVector<Value> dynDims;
        dynDims.resize(cast<ShapedType>(op->getResult(0).getType()).getRank());

        if (!outputTy.hasRank() || outputTy.isDynamicDim(0)) {
            dynDims[0] = tensor::DimOp::create(rewriter, loc, op->getOperand(0), 0);
        }
        if (!outputTy.hasRank() || outputTy.isDynamicDim(1)) {
            dynDims[1] = tensor::DimOp::create(rewriter, loc, op->getOperand(0), 1);
        }
        if (!outputTy.hasRank() || outputTy.isDynamicDim(0)) {
            dynDims[2] = tensor::DimOp::create(rewriter, loc, op->getOperand(1), 2);
        }

        SmallVector<Value> filteredDims = condenseValues(dynDims);

        auto zeroAttr = rewriter.getZeroAttr(outputElementTy);
        Value zero = arith::ConstantOp::create(rewriter, loc, zeroAttr);
        auto emptyTensor =
        tensor::EmptyOp::create(rewriter, loc, outputTy.getShape(),
                                outputTy.getElementType(), filteredDims);
        Value zeroTensor = linalg::FillOp::create(rewriter, loc, ValueRange{zero},
                                                ValueRange{emptyTensor})
                            .result();

        rewriter.replaceOpWithNewOp<linalg::BatchMatmulOp>(
            op, TypeRange{op.getType()},
            ValueRange{adaptor.getA(), adaptor.getB()}, ValueRange{zeroTensor});
        return success();
    }
};

void mlir::llnir::populateLLNIRToNPUConversionPatterns(
    const TypeConverter &convert, RewritePatternSet &patterns,
    const LLNIRToNPUOptions &options) {
    patterns.add<
        MatMulConverter
    >(patterns.getContext());
}