#include "llnmlir/Dialect/LLNIR/IR/LLNIR.h"
#include "llnmlir/Dialect/LLNIR/Utils/BaseUtils.h"

using namespace mlir;
using namespace mlir::llnir;

OpFoldResult llnir::ConstOp::fold(FoldAdaptor adaptor) { return getValuesAttr(); }

LogicalResult llnir::ConstOp::verify() {

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