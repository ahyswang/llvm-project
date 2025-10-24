#include "Standalone/IR/Standalone.h"
#include "Standalone/Utils/BaseUtils.h"

using namespace mlir;
using namespace mlir::standalone;

NARY_SHAPE_INFER(standalone::AddOp)


OpFoldResult standalone::AddOp::fold(FoldAdaptor adaptor) {
    auto lhsTy = llvm::dyn_cast<RankedTensorType>(getInput1().getType());
    auto rhsTy = llvm::dyn_cast<RankedTensorType>(getInput2().getType());
    auto resultTy = llvm::dyn_cast<RankedTensorType>(getType());
    if (!lhsTy || !rhsTy || !resultTy)
        return {};
  
    // Cannot create an ElementsAttr from non-int/float/index types
    if (!lhsTy.getElementType().isIntOrIndexOrFloat() ||
        !rhsTy.getElementType().isIntOrIndexOrFloat())
        return {};
  
    auto resultETy = resultTy.getElementType();
    auto lhsAttr =
        llvm::dyn_cast_if_present<DenseElementsAttr>(adaptor.getInput1());
    auto rhsAttr =
        llvm::dyn_cast_if_present<DenseElementsAttr>(adaptor.getInput2());
  
    if (lhsTy == resultTy && isSplatZero(resultETy, rhsAttr))
        return getInput1();
    if (rhsTy == resultTy && isSplatZero(resultETy, lhsAttr))
        return getInput2();
  
    if (!lhsAttr || !rhsAttr)
        return {};
  
    return binaryFolder<std::plus<APInt>, std::plus<APFloat>>(lhsAttr, rhsAttr,
                                                                resultTy);
}