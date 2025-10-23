//===- StandaloneOps.h - Standalone dialect ops -----------------*- C++ -*-===//
//
// This file is licensed under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef STANDALONE_STANDALONEOPS_H
#define STANDALONE_STANDALONEOPS_H

#include "mlir/IR/BuiltinTypes.h"
#include "mlir/IR/Dialect.h"
#include "mlir/IR/OpDefinition.h"
#include "mlir/Interfaces/InferTypeOpInterface.h"
#include "mlir/Interfaces/SideEffectInterfaces.h"
#include "mlir/Bytecode/BytecodeOpInterface.h"

namespace mlir {

//===----------------------------------------------------------------------===//
// Operation Trait Types
//===----------------------------------------------------------------------===//

namespace OpTrait {
namespace standalone {

template <typename ConcreteType>
class StandaloneOperatorTrait
    : public TraitBase<ConcreteType, StandaloneOperatorTrait> {
    static LogicalResult verifyTrait(Operation *op) {
        llvm::outs() << "StandaloneOperatorTrait::verifyTrait, op name:" << op->getName() << "\n";
        return success();    
    }
};

/// This class indicates that an op is tosa-elementwise (permits broadcasting,
/// unlike Elementwise trait).
template <typename ConcreteType>
class StandaloneElementwiseOperator
    : public TraitBase<ConcreteType, StandaloneElementwiseOperator> {};

} // standalone
} // namespace Traits 

} // namespace mlir
#define GET_OP_CLASSES
#include "Standalone/StandaloneOps.h.inc"




#endif // STANDALONE_STANDALONEOPS_H
