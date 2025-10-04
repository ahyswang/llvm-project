// FuseMulAddPass.cpp - Pass to fuse mul and add into mla op  --- IGNORE ---
#include "mlir/Dialect/Arith/IR/Arith.h"
#include "mlir/Dialect/Func/IR/FuncOps.h"
#include "mlir/IR/BuiltinOps.h"
#include "mlir/IR/PatternMatch.h"
#include "mlir/Pass/Pass.h"
#include "mlir/Transforms/GreedyPatternRewriteDriver.h"

using namespace mlir;

namespace {

struct MulAddFusionPattern : public OpRewritePattern<arith::MulFOp> {
  using OpRewritePattern<arith::MulFOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(arith::MulFOp mulOp,
                                PatternRewriter &rewriter) const override {
    // 检查加法操作的一个操作数是否是乘法结果
    auto addOp = mulOp.getRhs().getDefiningOp<arith::AddFOp>();
    if (!addOp) {
      return failure();
    }
    // A * (B + C) => C = A*B + A*C
    Value a = mulOp.getLhs();
    Value b = addOp.getLhs();
    Value c = addOp.getRhs();
    // 创建一个新的乘加操作
    rewriter.replaceOpWithNewOp<arith::AddFOp>(
        mulOp, rewriter.create<arith::MulFOp>(addOp.getLoc(), a, b),
        rewriter.create<arith::MulFOp>(addOp.getLoc(), a, c));
    return success();
  }
};

struct FuseMulAddPass
    : public PassWrapper<FuseMulAddPass, OperationPass<func::FuncOp>> {

  MLIR_DEFINE_EXPLICIT_INTERNAL_INLINE_TYPE_ID(FuseMulAddPass)
  void getDependentDialects(DialectRegistry &registry) const override {
    registry.insert<arith::ArithDialect>();
  }

  StringRef getArgument() const final { return "fuse-mul-add"; }

  StringRef getDescription() const final {
    return "Fuse multiplication followed by addition int a fuse multiply-add "
           "operation";
  }

  void runOnOperation() override {
    func::FuncOp func = getOperation();
    MLIRContext *context = &getContext();
    RewritePatternSet patterns(context);

    // Pattern to match mul followed by add and replace with mla
    patterns.add<struct MulAddFusionPattern>(context);

    if (failed(applyPatternsAndFoldGreedily(func, std::move(patterns)))) {
      signalPassFailure();
    }
  }
};
} // namespace

std::unique_ptr<Pass> createFuseMulAddPass() {
  return std::make_unique<FuseMulAddPass>();
}

void registerFuseMulAddPasses() { PassRegistration<FuseMulAddPass>(); }