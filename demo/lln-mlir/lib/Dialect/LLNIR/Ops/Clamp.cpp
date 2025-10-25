#include "llnmlir/Dialect/LLNIR/IR/LLNIR.h"
#include "llnmlir/Dialect/LLNIR/Utils/BaseUtils.h"

using namespace mlir;
using namespace mlir::llnir;

NARY_SHAPE_INFER(llnir::ClampOp)

ParseResult ClampOp::parse(OpAsmParser &parser, OperationState &result)  {
    return parseWithEnumHandling<llnir::NanPropagationMode>(parser, result);
}

void ClampOp::print(OpAsmPrinter &parser) {
    return printWithNanPropagationHandling(parser, this->getOperation());
}

LogicalResult ClampOp::verify() {
    mlir::Type inputETy =
        llvm::cast<ShapedType>(getInput().getType()).getElementType();
    if (auto quantType =
            llvm::dyn_cast<mlir::quant::UniformQuantizedType>(inputETy)) {
      inputETy = quantType.getStorageType();
    }
    mlir::Type outputETy =
        llvm::cast<ShapedType>(getOutput().getType()).getElementType();
    if (auto quantType =
            llvm::dyn_cast<mlir::quant::UniformQuantizedType>(outputETy)) {
      outputETy = quantType.getStorageType();
    }
    if (inputETy != outputETy)
      return emitOpError("input/output element types are incompatible.");
  
    auto maxValAttr = getMaxValAttr();
    auto minValAttr = getMinValAttr();
  
    unsigned dataTypeBitWidth = inputETy.getIntOrFloatBitWidth();
  
    if (inputETy.isInteger(dataTypeBitWidth)) {
      // if input datatype is integer, check that the min_val/max_val attributes
      // are integer attributes, and that their type is the same as the input's
      // datatype
      auto intMaxValAttr = mlir::dyn_cast<mlir::IntegerAttr>(maxValAttr);
      auto intMinValAttr = mlir::dyn_cast<mlir::IntegerAttr>(minValAttr);
      if (!intMaxValAttr || !intMinValAttr ||
          (intMaxValAttr.getType() != intMinValAttr.getType()) ||
          (intMaxValAttr.getType() != inputETy))
        return emitOpError("min/max attributes types are incompatible with "
                           "input/output element types.");
  
      const bool isUnsigned = inputETy.isUnsignedInteger();
      const bool isBoolean = inputETy.isInteger(1);
      const APInt minVal = intMinValAttr.getValue();
      const APInt maxVal = intMaxValAttr.getValue();
      if ((isUnsigned || isBoolean) ? maxVal.ult(minVal) : maxVal.slt(minVal))
        return emitOpError("expected min_val <= max_val, got min_val=")
               << minValAttr << ", max_val=" << maxValAttr;
    } else {
      // otherwise, input datatype is float, check that the min_val/max_val
      // attributes share the same type and that their type is the same as the
      // input's datatype
      auto floatMaxValAttr = mlir::dyn_cast<mlir::FloatAttr>(maxValAttr);
      auto floatMinValAttr = mlir::dyn_cast<mlir::FloatAttr>(minValAttr);
      if (!floatMaxValAttr || !floatMinValAttr ||
          (floatMaxValAttr.getType() != floatMinValAttr.getType()) ||
          (floatMaxValAttr.getType() != inputETy))
        return emitOpError("min/max attributes types are incompatible with "
                           "input/output element types.");
  
      const APFloat minVal = floatMinValAttr.getValue();
      const APFloat maxVal = floatMaxValAttr.getValue();
      if (minVal.isNaN() || maxVal.isNaN())
        return emitOpError("min/max attributes should not be 'NaN', got min_val=")
               << minValAttr << ", max_val=" << maxValAttr;
  
      if (maxVal < minVal)
        return emitOpError("expected min_val <= max_val, got min_val=")
               << minValAttr << ", max_val=" << maxValAttr;
    }
  
    return success();
  }
  