//===- LLNIRPsss.td - LLNIR dialect passes -------*- tablegen -*-===//
//
// This file is licensed under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef LLNIR_PASS
#define LLNIR_PASS

include "mlir/Pass/PassBase.td"

def LLNIRSwitchBarFoo: Pass<"llnir-switch-bar-foo", "::mlir::ModuleOp"> {
  let summary = "Switches the name of a FuncOp named `bar` to `foo` and folds.";
  let description = [{
    Switches the name of a FuncOp named `bar` to `foo` and folds.
    ```
    func.func @bar() {
      return
    }
    // Gets transformed to:
    func.func @foo() {
      return
    }
    ```
  }];
}

def LLNIRInferShapesPass : Pass<"llnir-infer-shapes", "func::FuncOp"> {
  let summary = "Propagate shapes across LLNIR operations";
  let description = [{
    Pass that uses operand types and propagates shapes to LLNIR operations.
    This includes legalizing rankless and dynamic shapes towards static.
  }];

  let dependentDialects = [
    "func::FuncDialect",
    "tensor::TensorDialect",
    "llnir::LLNIRDialect",
  ];
}

#endif // LLNIR_PASS
