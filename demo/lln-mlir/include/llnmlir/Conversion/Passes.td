#ifndef LLNMLIR_CONVERSION_PASSES_TD
#define LLNMLIR_CONVERSION_PASSES_TD

include "mlir/Pass/PassBase.td"

//===----------------------------------------------------------------------===//
// LLNIRToNPU
//===----------------------------------------------------------------------===//

def LLNIRToNPU
    : InterfacePass<"llnir-to-npu", "FunctionOpInterface"> {
  let summary = "Lower LLNIR to NPU operations";
  let description = [{
    Pass that converts LLNIR operations to the equivalent operations using the
    NPU operations.
  }];

  let options = [
      Option<"preferQuant", "prefer-quant",
           "bool", /*default=*/"false",
           "Prefer quant lowering">
  ];

  let constructor = "mlir::llnir::createLLNIRToNPU()";
}

#endif //LLNMLIR_CONVERSION_PASSES_TD