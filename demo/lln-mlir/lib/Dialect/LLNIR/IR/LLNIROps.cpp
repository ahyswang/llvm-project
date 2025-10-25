#include "llnmlir/Dialect/LLNIR/IR/LLNIR.h"
#include "llnmlir/Dialect/LLNIR/Utils/BaseUtils.h"

using namespace mlir;
using namespace mlir::llnir;

NARY_SHAPE_INFER(llnir::BitwiseAndOp)
NARY_SHAPE_INFER(llnir::BitwiseOrOp)
NARY_SHAPE_INFER(llnir::BitwiseXorOp)
NARY_SHAPE_INFER(llnir::BitwiseNotOp)
NARY_SHAPE_INFER(llnir::LeftshiftOp)
NARY_SHAPE_INFER(llnir::RightshiftOp)
NARY_SHAPE_INFER(llnir::NegativeOp)
NARY_SHAPE_INFER(llnir::QuantOp)
NARY_SHAPE_INFER(llnir::DequantOp) 











