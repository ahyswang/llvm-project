#include "llnmlir/Dialect/LLNIR/IR/LLNIR.h"
#include "llnmlir/Dialect/LLNIR/Utils/BaseUtils.h"

#include "mlir/IR/PatternMatch.h"

using namespace mlir;
using namespace mlir::llnir;

struct ClampIsNoOp : public OpRewritePattern<llnir::ClampOp> {
    using OpRewritePattern::OpRewritePattern;
    LogicalResult matchAndRewrite(llnir::ClampOp op, 
                                 PatternRewriter &rewrite) const override {
        Value input = op.getInput();
        auto inputType = llvm::dyn_cast<RankedTensorType>(op.getInput().getType());
        auto inputElementType = inputType.getElementType();

        if (isa<IntegerType>(inputElementType)) {
            const int64_t minClamp = llvm::cast<mlir::IntegerAttr>(op.getMinValAttr()).getInt();
            const int64_t maxClamp = llvm::cast<mlir::IntegerAttr>(op.getMaxValAttr()).getInt();

            const unsigned bitwidth = inputElementType.getIntOrFloatBitWidth();
            const int64_t intMin = APInt::getSignedMinValue(bitwidth).getSExtValue();
            const int64_t intMax = APInt::getSignedMaxValue(bitwidth).getSExtValue();

            if (minClamp <= intMin && maxClamp >= intMax) {
                rewrite.replaceOp(op, input);
                return success();
            }
        }

        return failure();
    }           
};

void ClampOp::getCanonicalizationPatterns(RewritePatternSet &results,
                                          MLIRContext *context) {
    results.add<ClampIsNoOp>(context);
}