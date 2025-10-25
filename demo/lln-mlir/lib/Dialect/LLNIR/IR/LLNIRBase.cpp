//===- LLNIRDialect.cpp - LLNIR dialect ---------------*- C++ -*-===//
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

#include "llnmlir/Dialect/LLNIR/IR/LLNIR.h"

using namespace mlir;
using namespace mlir::llnir;

//===----------------------------------------------------------------------===//
// LLNIR dialect and structs define.
//===----------------------------------------------------------------------===//

#include "llnmlir/Dialect/LLNIR/IR/LLNIROpsDialect.cpp.inc"
#include "llnmlir/Dialect/LLNIR/IR/LLNIRInterfaces.cpp.inc"
#include "llnmlir/Dialect/LLNIR/IR/LLNIREnums.cpp.inc"
#define GET_ATTRDEF_CLASSES
#include "llnmlir/Dialect/LLNIR/IR/LLNIRAttributes.cpp.inc"
#define GET_TYPEDEF_CLASSES
#include "llnmlir/Dialect/LLNIR/IR/LLNIROpsTypes.cpp.inc"
#define GET_OP_CLASSES
#include "llnmlir/Dialect/LLNIR/IR/LLNIROps.cpp.inc"

//===----------------------------------------------------------------------===//
// LLNIR dialect.
//===----------------------------------------------------------------------===//

void LLNIRDialect::initialize() {
  addTypes<
#define GET_TYPEDEF_LIST
#include "llnmlir/Dialect/LLNIR/IR/LLNIROpsTypes.cpp.inc"
      >();
  addAttributes<
#define GET_ATTRDEF_LIST
#include "llnmlir/Dialect/LLNIR/IR/LLNIRAttributes.cpp.inc"
      >();
  addOperations<
#define GET_OP_LIST
#include "llnmlir/Dialect/LLNIR/IR/LLNIROps.cpp.inc"
      >();
}

// TODO
Operation *llnir::LLNIRDialect::materializeConstant(OpBuilder &builder, Attribute value,
  Type type, Location loc) {
  // Tosa dialect constants only support ElementsAttr unlike standard dialect
  // constant which supports all attributes.
  // if (llvm::isa<shapeType>(type) && llvm::isa<DenseIntElementsAttr>(value)) {
  //   return tosa::ConstShapeOp::create(builder, loc, type,
  //     llvm::cast<DenseIntElementsAttr>(value));
  // }
  if (llvm::isa<ElementsAttr>(value))
    return llnir::ConstOp::create(builder, loc, type,
        llvm::cast<ElementsAttr>(value));
  return nullptr;
}

//===----------------------------------------------------------------------===//
// LLNIR shapeType.
//===----------------------------------------------------------------------===//

LogicalResult shapeType::verify(function_ref<InFlightDiagnostic()> emitError,
                              int rank) {
  if (rank < 0)
    return emitError() << "invalid rank (must be >= 0): " << rank;
  return success();
}


//===----------------------------------------------------------------------===//
// LLNIR operation validation includes.
//===----------------------------------------------------------------------===//

LogicalResult verifyLLNIRResolvableShapeOperands(Operation *op) {
  for (auto v : op->getOperands()) {
      if (mlir::isa<::mlir::llnir::shapeType>(v.getType())) {
          Operation *definingOp = v.getDefiningOp();
          if (!definingOp || !definingOp->hasTrait<LLNIRShapeOperator>()) {
              return op->emitOpError("shape operand is not compile time resolvable");
          }
      }
  }
  return success();
}

LogicalResult verifyLLNIRShapeOperator(Operation *op) {
  for (auto type : op->getOperandTypes()) {
      if (!mlir::isa<mlir::llnir::shapeType>(type)) {
          return op->emitOpError("must have operands with llnir shape type");
      }
  }
  for (auto type : op->getResultTypes()) {
      if (!mlir::isa<mlir::llnir::shapeType>(type)) {
          return op->emitOpError("must have result with llnir shape type");
      }
  }
  return success();
}
  




