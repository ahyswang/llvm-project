#ifndef MLIR_DIALECT_LLNIR_IR_LLNIRTRAITS_H
#define MLIR_DIALECT_LLNIR_IR_LLNIRTRAITS_H

#include "mlir/IR/OpDefinition.h"
#include "mlir/IR/BuiltinTypes.h"

//===----------------------------------------------------------------------===//
// LLNIR operation validation includes.
//===----------------------------------------------------------------------===//

namespace mlir {
namespace llnir {
    
    template <typename ConcreteType>
    class LLNIROperatorTrait
        : public OpTrait::TraitBase<ConcreteType, LLNIROperatorTrait> {
        static LogicalResult verifyTrait(Operation *op) {
            llvm::outs() << "LLNIROperatorTrait::verifyTrait, op name:" << op->getName() << "\n";
            return success();    
        }
    };
    
    /// This class indicates that an op is tosa-elementwise (permits broadcasting,
    /// unlike Elementwise trait).
    template <typename ConcreteType>
    class LLNIRElementwiseOperator
        : public OpTrait::TraitBase<ConcreteType, LLNIRElementwiseOperator> {};
    
    LogicalResult verifyLLNIRResolvableShapeOperands(Operation *op);
    /// This class verifies that tosa shape operands are compile time resolvable
    template <typename ConcreteType>
    class LLNIRResolvableShapeOperands
        : public OpTrait::TraitBase<ConcreteType, LLNIRResolvableShapeOperands> {
    public:
        static LogicalResult verifyTrait(Operation *op) {
            return verifyLLNIRResolvableShapeOperands(op);
        }
    };
    
    LogicalResult verifyLLNIRShapeOperator(Operation *op);
    /// This class indicates that op operates on tosa shape types
    template <typename ConcreteType>
    class LLNIRShapeOperator : public OpTrait::TraitBase<ConcreteType, LLNIRShapeOperator> {
    public:
        static LogicalResult verifyTrait(Operation *op) {
        return verifyLLNIRShapeOperator(op);
        }
    };

} // llnir
} // namespace mlir

#endif // MLIR_DIALECT_LLNIR_IR_LLNIRTRAITS_H