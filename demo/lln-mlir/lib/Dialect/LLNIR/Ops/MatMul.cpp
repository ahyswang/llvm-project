#include "llnmlir/Dialect/LLNIR/IR/LLNIR.h"
#include "llnmlir/Dialect/LLNIR/Utils/BaseUtils.h"

using namespace mlir;
using namespace mlir::llnir;

  LogicalResult MatMulOp::inferReturnTypeComponents(
      MLIRContext *context, ::std::optional<Location> location,
      MatMulOp::Adaptor adaptor,
      SmallVectorImpl<ShapedTypeComponents> &inferredReturnShapes) {
    llvm::SmallVector<int64_t> outputShape(4, ShapedType::kDynamic);
  
    ShapeAdaptor lhsShape(adaptor.getA().getType());
    ShapeAdaptor rhsShape(adaptor.getB().getType());

    // All shapes are dynamic
    SmallVector<int64_t> outShape;
    outShape.resize(3, ShapedType::kDynamic);

    if (lhsShape.hasRank()) {
      outShape[0] = lhsShape.getDimSize(0);
      outShape[1] = lhsShape.getDimSize(1);
    }
    if (rhsShape.hasRank()) {
      outShape[0] = outShape[0] == ShapedType::kDynamic ? rhsShape.getDimSize(0)
                                                      : outShape[0];
      outShape[2] = rhsShape.getDimSize(2);
    }
  
    inferredReturnShapes.push_back(ShapedTypeComponents(outShape));
    return success();
  }
  
  // LogicalResult MatMulOp::verify() {
  //   //TODO:
  //   return success();
  // }