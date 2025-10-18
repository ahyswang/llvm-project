//===- StandaloneOps.cpp - Standalone dialect ops ---------------*- C++ -*-===//
//
// This file is licensed under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "Standalone/StandaloneOps.h"
#include "Standalone/StandaloneDialect.h"
#include "Standalone/StandaloneTypes.h"

#define GET_OP_CLASSES
#include "Standalone/StandaloneOps.cpp.inc"

using namespace mlir;

//===----------------------------------------------------------------------===//
// TOSA Shape and Shape Operators Helper functions.
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
// Standalone operation validation includes.
//===----------------------------------------------------------------------===//

namespace mlir {

    namespace OpTrait {
    namespace standalone {
    
    LogicalResult verifyStandaloneResolvableShapeOperands(Operation *op);
    /// This class verifies that tosa shape operands are compile time resolvable
    template <typename ConcreteType>
    class StandaloneResolvableShapeOperands
        : public TraitBase<ConcreteType, StandaloneResolvableShapeOperands> {
    public:
        static LogicalResult verifyTrait(Operation *op) {
            return verifyStandaloneResolvableShapeOperands(op);
        }
    };
    
    LogicalResult verifyStandaloneShapeOperator(Operation *op);
    /// This class indicates that op operates on tosa shape types
    template <typename ConcreteType>
    class StandaloneShapeOperator : public TraitBase<ConcreteType, StandaloneShapeOperator> {
    public:
      static LogicalResult verifyTrait(Operation *op) {
        return verifyStandaloneShapeOperator(op);
      }
    };
    
} // namespace Standalone
} // namespace OpTrait
} // namespace mlir

LogicalResult mlir::OpTrait::standalone::verifyStandaloneResolvableShapeOperands(Operation *op) {
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

LogicalResult mlir::OpTrait::standalone::verifyStandaloneShapeOperator(Operation *op) {
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

//===----------------------------------------------------------------------===//
// TOSA Operator Return Type Inference.
//===----------------------------------------------------------------------===//

static LogicalResult resolveBroadcastShape(const ValueShapeRange &operands,
                                           SmallVector<int64_t> &outShape) {
  int64_t outRank = 0;
  for (int i = 0, e = operands.size(); i != e; ++i) {
    auto shape = operands.getShape(i);
    if (!shape.hasRank()) {
      // TODO(jennik): Update function to have better case handling for
      // invalid operands and for ranked tensors.
      return failure();
    }
    outRank = std::max<int64_t>(outRank, shape.getRank());
  }

  outShape.resize(outRank, 1);

  for (int i = 0, e = operands.size(); i != e; ++i) {
    auto shape = operands.getShape(i);
    auto rankDiff = outShape.size() - shape.getRank();

    for (size_t i = 0, e = shape.getRank(); i < e; ++i) {
      auto dim1 = outShape[i + rankDiff];
      auto dim2 = shape.getDimSize(i);
      auto resolvedDim = dim1;

      if (dim1 == 1) {
        resolvedDim = dim2;
      } else if (dim2 == 1) {
        resolvedDim = dim1;
      } else if (dim1 != dim2) {
        return failure();
      }
      outShape[i + rankDiff] = resolvedDim;
    }
  }

  return success();
}

static LogicalResult NAryInferReturnTypes(
    const ValueShapeRange &operands,
    SmallVectorImpl<ShapedTypeComponents> &inferredReturnShapes) {
  llvm::SmallVector<int64_t> outShape;
  if (resolveBroadcastShape(operands, outShape).failed()) {
    inferredReturnShapes.push_back(ShapedTypeComponents());
  } else {
    inferredReturnShapes.push_back(ShapedTypeComponents(outShape));
  }
  return success();
}

// #define NARY_SHAPE_INFER(OP)  
// LogicalResult OP::inferReturnTypeComponents(                                 \
//     MLIRContext *context, ::std::optional<Location> location,                \
//     ValueShapeRange operands, DictionaryAttr attributes,                     \
//     OpaqueProperties properties, RegionRange regions,                        \
//     SmallVectorImpl<ShapedTypeComponents> &inferredReturnShapes) {           \
//   return NAryInferReturnTypes(operands, inferredReturnShapes);               \
// }

// NARY_SHAPE_INFER(standalone::AddOp)


LogicalResult standalone::AddOp::inferReturnTypeComponents(                                 \
    MLIRContext *context, ::std::optional<Location> location,                \
    ValueShapeRange operands, DictionaryAttr attributes,                     \
    OpaqueProperties properties, RegionRange regions,                        \
    SmallVectorImpl<ShapedTypeComponents> &inferredReturnShapes) {           \
  return NAryInferReturnTypes(operands, inferredReturnShapes);               \
}