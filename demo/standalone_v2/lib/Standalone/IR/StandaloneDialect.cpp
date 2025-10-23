//===- StandaloneDialect.cpp - Standalone dialect ---------------*- C++ -*-===//
//
// This file is licensed under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "mlir/Dialect/Tensor/IR/Tensor.h"
#include "mlir/Dialect/Quant/IR/Quant.h"

#include "Standalone/IR/StandaloneDialect.h"
#include "Standalone/IR/StandaloneOps.h"
#include "Standalone/IR/StandaloneTypes.h"

using namespace mlir;
using namespace mlir::standalone;

#include "Standalone/IR/StandaloneOpsDialect.cpp.inc"

//===----------------------------------------------------------------------===//
// Standalone dialect.
//===----------------------------------------------------------------------===//

void StandaloneDialect::initialize() {
  registerOps();
  registerTypes();
}
