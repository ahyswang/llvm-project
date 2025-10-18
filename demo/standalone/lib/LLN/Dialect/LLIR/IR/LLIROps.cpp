//===----------------------------------------------------------------------===//
//
// Copyright (C) 2022 Sophgo Technologies Inc.  All rights reserved.
//
// LLIR-MLIR is licensed under the 2-Clause BSD License except for the
// third-party components.
//
//===----------------------------------------------------------------------===//
using namespace lln_mlir::llir;

//===----------------------------------------------------------------------===//
// Dialect initialize method.
//===----------------------------------------------------------------------===//
#include "LLN/Dialect/LLIR/IR/LLIROpsDialect.cpp.inc"

void LLIRDialect::initialize() {
  addAttributes<
#define GET_ATTRDEF_LIST
      >();
  addOperations<
#define GET_OP_LIST
#include "LLN/Dialect/LLIR/IR/LLIROps.cpp.inc"
      >();
}

//===----------------------------------------------------------------------===//
// Top Operator Definitions.
//===----------------------------------------------------------------------===//
#define GET_ATTRDEF_CLASSES

#define GET_OP_CLASSES
#include "LLN/Dialect/LLIR/IR/LLIROps.cpp.inc"