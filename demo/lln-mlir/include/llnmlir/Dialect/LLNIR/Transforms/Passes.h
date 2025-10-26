//===- LLNIRPasses.h - LLNIR passes  ------------------*- C++ -*-===//
//
// This file is licensed under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
#ifndef MLIR_DIALECT_LLNIR_TRANSFORMS_PASSES_TD
#define MLIR_DIALECT_LLNIR_TRANSFORMS_PASSES_TD

#include "llnmlir/Dialect/LLNIR/Transforms/ShapeReification.h"

#include "llnmlir/Dialect/LLNIR/IR/LLNIR.h"
#include "mlir/Pass/Pass.h"
#include <memory>

namespace mlir {
namespace llnir {
#define GEN_PASS_DECL
#include "llnmlir/Dialect/LLNIR/Transforms/Passes.h.inc"

#define GEN_PASS_REGISTRATION
#include "llnmlir/Dialect/LLNIR/Transforms/Passes.h.inc"
} // namespace llnir
} // namespace mlir

#endif //MLIR_DIALECT_LLNIR_TRANSFORMS_PASSES_TD
