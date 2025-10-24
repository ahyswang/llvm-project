#include "Standalone/IR/Standalone.h"
#include "Standalone/Utils/BaseUtils.h"

using namespace mlir;
using namespace mlir::standalone;

NARY_SHAPE_INFER(standalone::BitwiseAndOp)
NARY_SHAPE_INFER(standalone::BitwiseOrOp)
NARY_SHAPE_INFER(standalone::BitwiseXorOp)
NARY_SHAPE_INFER(standalone::BitwiseNotOp)
NARY_SHAPE_INFER(standalone::LeftshiftOp)
NARY_SHAPE_INFER(standalone::RightshiftOp)
NARY_SHAPE_INFER(standalone::NegativeOp)
NARY_SHAPE_INFER(standalone::QuantOp)
NARY_SHAPE_INFER(standalone::DequantOp) 











