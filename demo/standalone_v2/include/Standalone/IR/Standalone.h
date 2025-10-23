#ifndef MLIR_DIALECT_STANDALONE_IR_STANDALONE_H
#define MLIR_DIALECT_STANDALONE_IR_STANDALONE_H

#include "mlir/Bytecode/BytecodeOpInterface.h"
#include "mlir/Dialect/Quant/IR/QuantTypes.h"
#include "mlir/Dialect/Traits.h"
#include "mlir/IR/Matchers.h"
#include "mlir/IR/OpDefinition.h"
#include "mlir/IR/OpImplementation.h"
#include "mlir/IR/BuiltinTypes.h"
#include "mlir/IR/Dialect.h"
#include "mlir/IR/TypeUtilities.h"
#include "mlir/Interfaces/InferTypeOpInterface.h"
#include "mlir/Interfaces/LoopLikeInterface.h"
#include "mlir/Interfaces/SideEffectInterfaces.h"
#include "mlir/Interfaces/VectorInterfaces.h"
#include "mlir/Transforms/DialectConversion.h"

//===----------------------------------------------------------------------===//
// Standalone dialect and structs includes.
//===----------------------------------------------------------------------===//

#include "Standalone/IR/StandaloneOpsDialect.h.inc"
#include "Standalone/IR/StandaloneEnums.h.inc"

namespace mlir {
namespace standalone {
#include "Standalone/IR/StandaloneInterfaces.h.inc"
} // namespace standalone
} // namespace mlir

//===----------------------------------------------------------------------===//
// Standalone operation validation includes.
//===----------------------------------------------------------------------===//

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


#define GET_TYPEDEF_CLASSES
#include "Standalone/IR/StandaloneOpsTypes.h.inc"

#define GET_OP_CLASSES
#include "Standalone/IR/StandaloneOps.h.inc"

#endif // MLIR_DIALECT_STANDALONE_IR_STANDALONE_H