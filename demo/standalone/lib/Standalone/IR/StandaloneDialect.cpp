//===- StandaloneDialect.cpp - Standalone dialect ---------------*- C++ -*-===//
//
// This file is licensed under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "mlir/Dialect/Tensor/IR/Tensor.h"
#include "mlir/Dialect/Quant/IR/Quant.h"
#include "mlir/Dialect/Quant/IR/QuantTypes.h"
#include "llvm/ADT/TypeSwitch.h"
#include "llvm/Support/LogicalResult.h"
#include "mlir/IR/DialectImplementation.h"

#include "Standalone/IR/Standalone.h"

using namespace mlir;
using namespace mlir::standalone;

//===----------------------------------------------------------------------===//
// Standalone dialect and structs define.
//===----------------------------------------------------------------------===//

#include "Standalone/IR/StandaloneOpsDialect.cpp.inc"
#include "Standalone/IR/StandaloneInterfaces.cpp.inc"
#include "Standalone/IR/StandaloneEnums.cpp.inc"
#define GET_ATTRDEF_CLASSES
#include "Standalone/IR/StandaloneAttributes.cpp.inc"
#define GET_TYPEDEF_CLASSES
#include "Standalone/IR/StandaloneOpsTypes.cpp.inc"
#define GET_OP_CLASSES
#include "Standalone/IR/StandaloneOps.cpp.inc"

//===----------------------------------------------------------------------===//
// Standalone dialect.
//===----------------------------------------------------------------------===//

void StandaloneDialect::initialize() {
  addTypes<
#define GET_TYPEDEF_LIST
#include "Standalone/IR/StandaloneOpsTypes.cpp.inc"
      >();
  addOperations<
#define GET_OP_LIST
#include "Standalone/IR/StandaloneOps.cpp.inc"
      >();
// addAttributes<
// #define GET_ATTRDEF_LIST
// #include #include "Standalone/IR/StandaloneOps.cpp.inc"
//       >();
}

// TODO
Operation *standalone::StandaloneDialect::materializeConstant(OpBuilder &builder, Attribute value,
  Type type, Location loc) {
  // Tosa dialect constants only support ElementsAttr unlike standard dialect
  // constant which supports all attributes.
  // if (llvm::isa<shapeType>(type) && llvm::isa<DenseIntElementsAttr>(value)) {
  //   return tosa::ConstShapeOp::create(builder, loc, type,
  //     llvm::cast<DenseIntElementsAttr>(value));
  // }
  if (llvm::isa<ElementsAttr>(value))
    return standalone::ConstOp::create(builder, loc, type,
        llvm::cast<ElementsAttr>(value));
  return nullptr;
}

//===----------------------------------------------------------------------===//
// Standalone shapeType.
//===----------------------------------------------------------------------===//

LogicalResult shapeType::verify(function_ref<InFlightDiagnostic()> emitError,
                              int rank) {
  if (rank < 0)
    return emitError() << "invalid rank (must be >= 0): " << rank;
  return success();
}


//===----------------------------------------------------------------------===//
// Standalone operation validation includes.
//===----------------------------------------------------------------------===//

LogicalResult verifyStandaloneResolvableShapeOperands(Operation *op) {
  for (auto v : op->getOperands()) {
      if (mlir::isa<::mlir::standalone::shapeType>(v.getType())) {
          Operation *definingOp = v.getDefiningOp();
          if (!definingOp || !definingOp->hasTrait<StandaloneShapeOperator>()) {
              return op->emitOpError("shape operand is not compile time resolvable");
          }
      }
  }
  return success();
}

LogicalResult verifyStandaloneShapeOperator(Operation *op) {
  for (auto type : op->getOperandTypes()) {
      if (!mlir::isa<mlir::standalone::shapeType>(type)) {
          return op->emitOpError("must have operands with standalone shape type");
      }
  }
  for (auto type : op->getResultTypes()) {
      if (!mlir::isa<mlir::standalone::shapeType>(type)) {
          return op->emitOpError("must have result with standalone shape type");
      }
  }
  return success();
}
  




