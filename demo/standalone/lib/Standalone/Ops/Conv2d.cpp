#include "Standalone/IR/Standalone.h"
#include "Standalone/Utils/BaseUtils.h"

using namespace mlir;
using namespace mlir::standalone;

  LogicalResult Conv2DOp::inferReturnTypeComponents(
      MLIRContext *context, ::std::optional<Location> location,
      Conv2DOp::Adaptor adaptor,
      SmallVectorImpl<ShapedTypeComponents> &inferredReturnShapes) {
    llvm::SmallVector<int64_t> outputShape(4, ShapedType::kDynamic);
  
    int64_t inputWidth = ShapedType::kDynamic;
    int64_t inputHeight = ShapedType::kDynamic;
    int64_t weightWidth = ShapedType::kDynamic;
    int64_t weightHeight = ShapedType::kDynamic;
  
    // Input shape describes input width/height and batch.
  
    ShapeAdaptor inputShape(adaptor.getInput().getType());
    if (inputShape.hasRank()) {
      outputShape[0] = inputShape.getDimSize(0);
      inputHeight = inputShape.getDimSize(1);
      inputWidth = inputShape.getDimSize(2);
    }
  
    // Weight shapes describes the filter width/height and the output channels.
    ShapeAdaptor weightShape(adaptor.getWeight().getType());
    if (weightShape.hasRank()) {
      outputShape[3] = weightShape.getDimSize(0);
      weightHeight = weightShape.getDimSize(1);
      weightWidth = weightShape.getDimSize(2);
    }
  
    // Bias shape can describe the output channels.
    ShapeAdaptor biasShape(adaptor.getBias().getType());
    if (biasShape.hasRank()) {
      outputShape[3] = ShapedType::isDynamic(outputShape[3])
                           ? biasShape.getDimSize(0)
                           : outputShape[3];
    }
  
    llvm::ArrayRef<int64_t> dilation = adaptor.getDilation();
    llvm::ArrayRef<int64_t> stride = adaptor.getStride();
    llvm::ArrayRef<int64_t> padding = adaptor.getPad();
  
    if (ShapedType::isStatic(inputHeight) && ShapedType::isStatic(weightHeight)) {
      int64_t inputSize = inputHeight + padding[0] + padding[1];
      int64_t filterSize = (weightHeight - 1) * dilation[0] + 1;
      int64_t unstridedResult = inputSize - filterSize + 1;
      outputShape[1] = (unstridedResult - 1) / stride[0] + 1;
    }
  
    if (ShapedType::isStatic(inputWidth) && ShapedType::isStatic(weightWidth)) {
      int64_t inputSize = inputWidth + padding[2] + padding[3];
      int64_t filterSize = (weightWidth - 1) * dilation[1] + 1;
      int64_t unstridedResult = inputSize - filterSize + 1;
      outputShape[2] = (unstridedResult - 1) / stride[1] + 1;
    }
  
    inferredReturnShapes.push_back(ShapedTypeComponents(outputShape));
    return success();
  }
  
  // LogicalResult Conv2DOp::verify() {
  //   if (verifyConvOp(*this).failed() || verifyConvOpModes(*this).failed() ||
  //       verifyConvOpErrorIf(*this).failed())
  //     return failure();
  //   return success();
  // }