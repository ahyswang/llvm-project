#ifndef MLIR_DIALECT_STANDALONE_IR_STANDALONETRAITS_H
#define MLIR_DIALECT_STANDALONE_IR_STANDALONETRAITS_H

#include "mlir/IR/OpDefinition.h"
#include "mlir/IR/BuiltinTypes.h"

//===----------------------------------------------------------------------===//
// Standalone operation validation includes.
//===----------------------------------------------------------------------===//

namespace mlir {
namespace standalone {
    
    template <typename ConcreteType>
    class StandaloneOperatorTrait
        : public OpTrait::TraitBase<ConcreteType, StandaloneOperatorTrait> {
        static LogicalResult verifyTrait(Operation *op) {
            llvm::outs() << "StandaloneOperatorTrait::verifyTrait, op name:" << op->getName() << "\n";
            return success();    
        }
    };
    
    /// This class indicates that an op is tosa-elementwise (permits broadcasting,
    /// unlike Elementwise trait).
    template <typename ConcreteType>
    class StandaloneElementwiseOperator
        : public OpTrait::TraitBase<ConcreteType, StandaloneElementwiseOperator> {};
    
    LogicalResult verifyStandaloneResolvableShapeOperands(Operation *op);
    /// This class verifies that tosa shape operands are compile time resolvable
    template <typename ConcreteType>
    class StandaloneResolvableShapeOperands
        : public OpTrait::TraitBase<ConcreteType, StandaloneResolvableShapeOperands> {
    public:
        static LogicalResult verifyTrait(Operation *op) {
            return verifyStandaloneResolvableShapeOperands(op);
        }
    };
    
    LogicalResult verifyStandaloneShapeOperator(Operation *op);
    /// This class indicates that op operates on tosa shape types
    template <typename ConcreteType>
    class StandaloneShapeOperator : public OpTrait::TraitBase<ConcreteType, StandaloneShapeOperator> {
    public:
        static LogicalResult verifyTrait(Operation *op) {
        return verifyStandaloneShapeOperator(op);
        }
    };

} // standalone
} // namespace mlir

#endif // MLIR_DIALECT_STANDALONE_IR_STANDALONETRAITS_H