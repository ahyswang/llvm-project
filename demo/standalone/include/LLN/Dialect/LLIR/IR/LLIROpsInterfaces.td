//===----------------------------------------------------------------------===//
//
// Copyright (C) 2022 Sophgo Technologies Inc.  All rights reserved.
//
// LLN-MLIR is licensed under the 2-Clause BSD License except for the
// third-party components.
//
//===----------------------------------------------------------------------===//

#ifndef LLN_MLIR_DIALECT_LLIR_LLIROPSINTERFACES_TD
#define LLN_MLIR_DIALECT_LLIR_LLIROPSINTERFACES_TD

include "mlir/IR/OpBase.td"

def ShapeInterface : OpInterface<"ShapeInterface"> {
  let description = [{
  }];
  let cppNamespace = "::lln_mlir";
  let methods = [
      InterfaceMethod<
        /*desc=*/[{
          if output shape is dynamic, inference output shape by input shape;
          or verify output shape
        }],
        /*retType=*/"void",
        /*methodName=*/"shape_inference",
        /*args=*/(ins)
      >,
  ];
}
#endif // LLN_MLIR_DIALECT_LLIR_LLIROPSINTERFACES_TD