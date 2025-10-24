//===- StandalonePasses.h - Standalone passes  ------------------*- C++ -*-===//
//
// This file is licensed under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
#ifndef MLIR_DIALECT_STANDALONE_TRANSFORMS_PASSES_TD
#define MLIR_DIALECT_STANDALONE_TRANSFORMS_PASSES_TD

#include "Standalone/IR/Standalone.h"
#include "mlir/Pass/Pass.h"
#include <memory>

namespace mlir {
namespace standalone {
#define GEN_PASS_DECL
#include "Standalone/Transforms/StandalonePasses.h.inc"

#define GEN_PASS_REGISTRATION
#include "Standalone/Transforms/StandalonePasses.h.inc"
} // namespace standalone
} // namespace mlir

#endif //MLIR_DIALECT_STANDALONE_TRANSFORMS_PASSES_TD
