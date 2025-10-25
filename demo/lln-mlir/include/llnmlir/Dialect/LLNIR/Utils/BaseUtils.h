//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// Class declarations for ops utilities meant to assist ops.
//
//===----------------------------------------------------------------------===//

#ifndef MLIR_DIALECT_LLNIR_UTILS_BASEUTILS_H
#define MLIR_DIALECT_LLNIR_UTILS_BASEUTILS_H

#include "mlir/Dialect/Tensor/IR/Tensor.h"
#include "mlir/Dialect/Quant/IR/Quant.h"
#include "mlir/Dialect/Quant/IR/QuantTypes.h"

#include "llnmlir/Dialect/LLNIR/IR/LLNIR.h"

using namespace mlir;
using namespace mlir::llnir;

//===----------------------------------------------------------------------===//
// Parsers and printers
//===----------------------------------------------------------------------===//

namespace mlir{
namespace llnir {

    // parse attributes with special handling for llnir enum attributes
    template <typename EnumType>
    ParseResult parseAttrEntryWithEnumHandling(OpAsmParser &parser,
                                               NamedAttrList &outAttrs);
    template <typename EnumType>
    ParseResult parseWithEnumHandling(OpAsmParser &parser, OperationState &result);
    // print with special handling for default valued NanPropagationMode attribute
    void printWithNanPropagationHandling(OpAsmPrinter &parser, Operation *op);
    // print with special handling for enums: RoundingMode, ResizeMode
    void printWithEnumHandling(OpAsmPrinter &parser, Operation *op);

} // namespace llnir
} // namespace mlir


//===----------------------------------------------------------------------===//
// TOSA Operator Return Type Inference.
//===----------------------------------------------------------------------===//

namespace mlir{
namespace llnir {

LogicalResult resolveBroadcastShape(const ValueShapeRange &operands,
                                        SmallVector<int64_t> &outShape);
LogicalResult NAryInferReturnTypes(
    const ValueShapeRange &operands,
    SmallVectorImpl<ShapedTypeComponents> &inferredReturnShapes);

#define NARY_SHAPE_INFER(OP)                                                   \
  LogicalResult OP::inferReturnTypeComponents(                                 \
      MLIRContext *context, ::std::optional<Location> location,                \
      ValueShapeRange operands, DictionaryAttr attributes,                     \
      OpaqueProperties properties, RegionRange regions,                        \
      SmallVectorImpl<ShapedTypeComponents> &inferredReturnShapes) {           \
    return NAryInferReturnTypes(operands, inferredReturnShapes);               \
  }

} // namespace llnir
} // namespace mlir


//===----------------------------------------------------------------------===//
// Operator Folders.
//===----------------------------------------------------------------------===//

namespace mlir{
namespace llnir {

template <typename IntFolder, typename FloatFolder>
DenseElementsAttr binaryFolder(DenseElementsAttr lhs, DenseElementsAttr rhs,
                               RankedTensorType returnTy) {
  if (rhs && lhs && rhs.isSplat() && lhs.isSplat()) {
    auto lETy = llvm::cast<ShapedType>(lhs.getType()).getElementType();
    auto rETy = llvm::cast<ShapedType>(rhs.getType()).getElementType();
    if (lETy != rETy)
      return {};

    if (llvm::isa<IntegerType>(lETy)) {
      APInt l = lhs.getSplatValue<APInt>();
      APInt r = rhs.getSplatValue<APInt>();
      auto result = IntFolder()(l, r);
      return DenseElementsAttr::get(returnTy, result);
    }

    if (llvm::isa<FloatType>(lETy)) {
      APFloat l = lhs.getSplatValue<APFloat>();
      APFloat r = rhs.getSplatValue<APFloat>();
      auto result = FloatFolder()(l, r);
      return DenseElementsAttr::get(returnTy, result);
    }
  }

  return {};
}

bool isSplatZero(Type elemType, DenseElementsAttr val);

bool isSplatOne(Type elemType, DenseElementsAttr val, int64_t shift);

template <typename Cmp>
struct ComparisonFold {
    ComparisonFold() = default;
    APInt operator()(const APInt &l, const APInt &r) {
    return APInt(1, Cmp()(l, r));
    }

    APInt operator()(const APFloat &l, const APFloat &r) {
    return APInt(1, Cmp()(l, r));
    }
};

struct APIntFoldGreater {
    APIntFoldGreater() = default;
    APInt operator()(const APInt &l, const APInt &r) {
    return APInt(1, l.sgt(r));
    }
};

struct APIntFoldGreaterEqual {
    APIntFoldGreaterEqual() = default;
    APInt operator()(const APInt &l, const APInt &r) {
    return APInt(1, l.sge(r));
    }
};

} // namespace llnir
} // namespace mlir

#endif // MLIR_DIALECT_LLNIR_UTILS_BASEUTILS_H