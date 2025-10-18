//===-- Passes.td - Calibration pass declarations ----------*- tablegen -*-===//
//
// Copyright (C) 2022 LLN Technologies Inc.  All rights reserved.
//
// LLN-MLIR is licensed under the 2-Clause BSD License except for the
// third-party components.
//
//===----------------------------------------------------------------------===//
//
// This file declares the passes for the LLIR Dialect to the LLN Dialect.
//
//===----------------------------------------------------------------------===//

#ifndef LLN_MLIR_DIALECT_LLIR_PASSES_TD
#define LLN_MLIR_DIALECT_LLIR_PASSES_TD

include "mlir/Pass/PassBase.td"

def ShapeInfer : Pass<"shape-infer", "ModuleOp"> {
  let summary = "do shape inference for each op";
  let constructor = "createShapeInferPass()";
  let dependentDialects = ["LLIRDialect"];
}

#endif //LLN_MLIR_DIALECT_LLIR_PASSES_TD