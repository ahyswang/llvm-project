#include "llnmlir/Dialect/LLNIR/IR/LLNIR.h"
#include "llnmlir/Dialect/LLNIR/Utils/BaseUtils.h"

using namespace mlir;
using namespace mlir::llnir;

NARY_SHAPE_INFER(llnir::ClampOp)

ParseResult ClampOp::parse(OpAsmParser &parser, OperationState &result)  {
    return parseWithEnumHandling<llnir::NanPropagationMode>(parser, result);
}

void ClampOp::print(OpAsmPrinter &parser) {
    return printWithNanPropagationHandling(parser, this->getOperation());
}