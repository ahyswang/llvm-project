#ifndef MLIR_DIALECT_LLNIR_IR_LLNIR_H
#define MLIR_DIALECT_LLNIR_IR_LLNIR_H

#include "mlir/Bytecode/BytecodeOpInterface.h"
#include "mlir/Dialect/Quant/IR/QuantTypes.h"
#include "mlir/Dialect/Traits.h"
#include "mlir/IR/Matchers.h"
#include "mlir/IR/OpDefinition.h"
#include "mlir/IR/OpImplementation.h"
#include "mlir/IR/BuiltinTypes.h"
#include "mlir/IR/Dialect.h"
#include "mlir/IR/TypeUtilities.h"
#include "mlir/IR/Attributes.h"
#include "mlir/Interfaces/InferTypeOpInterface.h"
#include "mlir/Interfaces/LoopLikeInterface.h"
#include "mlir/Interfaces/SideEffectInterfaces.h"
#include "mlir/Interfaces/VectorInterfaces.h"
#include "mlir/Transforms/DialectConversion.h"

//===----------------------------------------------------------------------===//
// LLNIR dialect and structs includes.
//===----------------------------------------------------------------------===//

#include "llnmlir/Dialect/LLNIR/IR/LLNIROpsDialect.h.inc"
#include "llnmlir/Dialect/LLNIR/IR/LLNIREnums.h.inc"
#include "llnmlir/Dialect/LLNIR/IR/LLNIRInterfaces.h.inc"
#include "llnmlir/Dialect/LLNIR/IR/LLNIRTraits.h"

#define GET_TYPEDEF_CLASSES
#include "llnmlir/Dialect/LLNIR/IR/LLNIROpsTypes.h.inc"

#define GET_ATTRDEF_CLASSES
#include "llnmlir/Dialect/LLNIR/IR/LLNIRAttributes.h.inc"

#define GET_OP_CLASSES
#include "llnmlir/Dialect/LLNIR/IR/LLNIROps.h.inc"


#endif // MLIR_DIALECT_LLNIR_IR_LLNIR_H