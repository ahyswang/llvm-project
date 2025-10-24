#include "mlir/Dialect/Tensor/IR/Tensor.h"
#include "mlir/Dialect/Quant/IR/Quant.h"
#include "mlir/Dialect/Quant/IR/QuantTypes.h"

#include "Standalone/IR/Standalone.h"

using namespace mlir;
using namespace mlir::standalone;

//===----------------------------------------------------------------------===//
// Parsers and printers
//===----------------------------------------------------------------------===//

namespace mlir{
namespace standalone {

    // parse attributes with special handling for standalone enum attributes
    template <typename EnumType>
    ParseResult parseAttrEntryWithEnumHandling(OpAsmParser &parser,
                                                NamedAttrList &outAttrs) {
        llvm::StringRef name;
        if (parser.parseOptionalKeyword(&name) || parser.parseEqual())
            return failure();
    
        // special handling: rounding_mode accepts a *bare* RoundingMode enum
        // keyword.
        llvm::StringRef kw;
        if constexpr (std::is_same_v<EnumType, standalone::RoundingMode>) {
            if (name == "rounding_mode" &&
                succeeded(parser.parseOptionalKeyword(&kw))) {
                auto sym = symbolizeRoundingMode(kw);
                if (!sym)
                return parser.emitError(parser.getCurrentLocation())
                        << "invalid rounding_mode value: " << kw;
                auto attr = RoundingModeAttr::get(parser.getContext(), sym.value());
                outAttrs.push_back(NamedAttribute(name, attr));
                return success();
            }
        }
        // special handling: mode accepts a *bare* ResizeMode enum keyword.
        if constexpr (std::is_same_v<EnumType, standalone::ResizeMode>) {
            if (name == "mode" && succeeded(parser.parseOptionalKeyword(&kw))) {
                auto sym = symbolizeResizeMode(kw);
                if (!sym)
                return parser.emitError(parser.getCurrentLocation())
                        << "invalid resize mode value: " << kw;
                auto attr = ResizeModeAttr::get(parser.getContext(), sym.value());
                outAttrs.push_back(NamedAttribute(name, attr));
                return success();
            }
        }
        // special handling: nan_mode accepts a *bare* NanPropagationMode enum
        // keyword.
        if constexpr (std::is_same_v<EnumType, standalone::NanPropagationMode>) {
            if (name == "nan_mode" && succeeded(parser.parseOptionalKeyword(&kw))) {
                auto sym = symbolizeNanPropagationMode(kw);
                if (!sym)
                return parser.emitError(parser.getCurrentLocation())
                        << "invalid nan_mode value: " << kw;
                auto attr = NanPropagationModeAttr::get(parser.getContext(), sym.value());
                outAttrs.push_back(NamedAttribute(name, attr));
                return success();
            }
        }
    
        // Default path: parse any normal attribute literal, including fully qualified
        // enum keyword
        Attribute attr;
        return parser.parseAttribute(attr, name, outAttrs);
    }
    
    template <typename EnumType>
    ParseResult parseWithEnumHandling(OpAsmParser &parser, OperationState &result) {
        // parse operands
        SmallVector<OpAsmParser::UnresolvedOperand, 5> operands;
        if (parser.parseCommaSeparatedList(
                [&]() { return parser.parseOperand(operands.emplace_back()); }))
            return failure();
    
        // Parse { attr-dict } with special handling for enum bare token
        NamedAttrList attrs;
        if (succeeded(parser.parseOptionalLBrace()) &&
            failed(parser.parseOptionalRBrace())) {
        do {
            if (parseAttrEntryWithEnumHandling<EnumType>(parser, attrs))
                return failure();
        } while (succeeded(parser.parseOptionalComma()));
        if (parser.parseRBrace())
            return failure();
        }
    
        FunctionType fnTy;
        if (parser.parseColonType(fnTy))
            return failure();
    
        // Resolve operands and types
        if (failed(parser.resolveOperands(operands, fnTy.getInputs(),
                                        parser.getCurrentLocation(),
                                        result.operands)))
            return failure();
    
        result.addTypes(fnTy.getResult(0));
        result.addAttributes(attrs);
    
        return success();
    }
    
    static void printNamedAttr(OpAsmPrinter &parser, const NamedAttribute namedAttr) {
        parser << namedAttr.getName().strref() << " = ";
        auto attr = namedAttr.getValue();
        if (auto roundingModeAttr = dyn_cast<standalone::RoundingModeAttr>(attr)) {
            parser << roundingModeAttr.getValue();
        } else if (auto resizeModeAttr = dyn_cast<standalone::ResizeModeAttr>(attr)) {
            parser << resizeModeAttr.getValue();
        } else if (auto nanPropagationModeAttr =
                        dyn_cast<standalone::NanPropagationModeAttr>(attr)) {
            parser << nanPropagationModeAttr.getValue();
        } else {
            parser.printAttribute(attr);
        }
    }
    
    // print with special handling for default valued NanPropagationMode attribute
    void printWithNanPropagationHandling(OpAsmPrinter &parser, Operation *op) {
        parser << " ";
        parser.printOperands(op->getOperands());
    
        NamedAttrList toPrint(op->getAttrs());
        // remove default NanPropagate attribute
        const auto kDefaultNanValue = NanPropagationMode::PROPAGATE;
        for (auto attr : op->getAttrs()) {
            if (auto nanAttr = dyn_cast<NanPropagationModeAttr>(attr.getValue())) {
                if (nanAttr.getValue() == kDefaultNanValue) {
                // elide from toPrint
                toPrint.erase(attr.getName());
                break;
                }
            }
        }
    
        if (!toPrint.empty()) {
            parser << " {";
            llvm::interleaveComma(toPrint, parser, [&](const NamedAttribute namedAttr) {
                printNamedAttr(parser, namedAttr);
            });
            parser << "}";
        }
    
        parser << " : ";
        parser.printFunctionalType(op);
    }
    
    // print with special handling for enums: RoundingMode, ResizeMode
    void printWithEnumHandling(OpAsmPrinter &parser, Operation *op) {
        parser << " ";
        parser.printOperands(op->getOperands());
    
        if (!op->getAttrs().empty()) {
            parser << " {";
            llvm::interleaveComma(op->getAttrs(), parser,
                                    [&](const NamedAttribute namedAttr) {
                                    printNamedAttr(parser, namedAttr);
                                    });
            parser << "}";
        }
    
        parser << " : ";
        parser.printFunctionalType(op);
    }

    // instantiate the templates for the specific EnumTypes
    template ParseResult parseWithEnumHandling<standalone::RoundingMode>(
        OpAsmParser &parser, OperationState &result);
    template ParseResult parseWithEnumHandling<standalone::ResizeMode>(
        OpAsmParser &parser, OperationState &result);
    template ParseResult parseWithEnumHandling<standalone::NanPropagationMode>(
        OpAsmParser &parser, OperationState &result);

} // namespace standalone
} // namespace mlir
    

//===----------------------------------------------------------------------===//
// TOSA Operator Return Type Inference.
//===----------------------------------------------------------------------===//

namespace mlir{
namespace standalone {
    
LogicalResult resolveBroadcastShape(const ValueShapeRange &operands,
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

LogicalResult NAryInferReturnTypes(
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

} // namespace standalone
} // namespace mlir


//===----------------------------------------------------------------------===//
// Operator Folders.
//===----------------------------------------------------------------------===//

namespace mlir{
namespace standalone {

bool isSplatZero(Type elemType, DenseElementsAttr val) {
    if (llvm::isa<FloatType>(elemType))
        return val && val.isSplat() && val.getSplatValue<APFloat>().isZero();
    if (llvm::isa<IntegerType>(elemType))
        return val && val.isSplat() && val.getSplatValue<APInt>().isZero();
    return false;
}

bool isSplatOne(Type elemType, DenseElementsAttr val, int64_t shift) {
    if (llvm::isa<FloatType>(elemType))
        return val && val.isSplat() &&
                val.getSplatValue<APFloat>().isExactlyValue(1.0);
    if (llvm::isa<IntegerType>(elemType)) {
        const int64_t shifted = 1LL << shift;
        return val && val.isSplat() &&
                val.getSplatValue<APInt>().getSExtValue() == shifted;
    }
    return false;
}

} // namespace standalone
} // namespace mlir