#ifndef LLNIR_OP_INTERFACES
#define LLNIR_OP_INTERFACES

include "mlir/IR/OpBase.td"

def LLNIROpInterface : OpInterface<"LLNIROp"> {
  let description = [{
    Implemented by ops that correspond to the LLNIR specification.
  }];
}

#endif //LLNIR_OP_INTERFACES