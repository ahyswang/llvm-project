#include "Standalone/IR/Standalone.h"
#include "Standalone/Utils/BaseUtils.h"

using namespace mlir;
using namespace mlir::standalone;

NARY_SHAPE_INFER(standalone::ClampOp)

ParseResult ClampOp::parse(OpAsmParser &parser, OperationState &result)  {
    return parseWithEnumHandling<standalone::NanPropagationMode>(parser, result);
}

void ClampOp::print(OpAsmPrinter &parser) {
    return printWithNanPropagationHandling(parser, this->getOperation());
}