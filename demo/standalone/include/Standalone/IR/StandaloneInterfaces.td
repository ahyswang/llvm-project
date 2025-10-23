#ifndef STANDALONE_OP_INTERFACES
#define STANDALONE_OP_INTERFACES

include "mlir/IR/OpBase.td"

def StandaloneOpInterface : OpInterface<"StandaloneOp"> {
  let description = [{
    Implemented by ops that correspond to the Standalone specification.
  }];
}

#endif //STANDALONE_OP_INTERFACES