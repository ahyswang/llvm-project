//===- StandaloneTypes.cpp - Standalone dialect types -----------*- C++ -*-===//
//
// This file is licensed under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "Standalone/IR/Standalone.h"

#include "mlir/IR/Builders.h"
#include "mlir/IR/DialectImplementation.h"
#include "llvm/ADT/TypeSwitch.h"
#include "llvm/Support/LogicalResult.h"

using namespace llvm;
using namespace mlir::standalone;

#define GET_TYPEDEF_CLASSES
#include "Standalone/IR/StandaloneOpsTypes.cpp.inc"

void StandaloneDialect::registerTypes() {
  addTypes<
#define GET_TYPEDEF_LIST
#include "Standalone/IR/StandaloneOpsTypes.cpp.inc"
      >();
}


LogicalResult
mlir::standalone::shapeType::verify(function_ref<InFlightDiagnostic()> emitError,
                              int rank) {
  if (rank < 0)
    return emitError() << "invalid rank (must be >= 0): " << rank;
  return success();
}
