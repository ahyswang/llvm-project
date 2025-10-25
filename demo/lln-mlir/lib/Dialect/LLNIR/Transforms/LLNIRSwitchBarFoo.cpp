//===- LLNIRPasses.cpp - LLNIR passes -----------------*- C++ -*-===//
//
// This file is licensed under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
#include "mlir/Dialect/Func/IR/FuncOps.h"
#include "mlir/IR/PatternMatch.h"
#include "mlir/Rewrite/FrozenRewritePatternSet.h"
#include "mlir/Transforms/GreedyPatternRewriteDriver.h"

#include "llnmlir/Dialect/LLNIR/Transforms/Passes.h"

namespace mlir::llnir {
#define GEN_PASS_DEF_LLNIRSWITCHBARFOO
#include "llnmlir/Dialect/LLNIR/Transforms/Passes.h.inc"

namespace {
class LLNIRSwitchBarFooRewriter : public OpRewritePattern<func::FuncOp> {
public:
  using OpRewritePattern<func::FuncOp>::OpRewritePattern;
  LogicalResult matchAndRewrite(func::FuncOp op,
                                PatternRewriter &rewriter) const final {
    if (op.getSymName() == "bar") {
      rewriter.modifyOpInPlace(op, [&op]() { op.setSymName("foo"); });
      return success();
    }
    return failure();
  }
};

class LLNIRSwitchBarFoo
    : public impl::LLNIRSwitchBarFooBase<LLNIRSwitchBarFoo> {
public:
  using impl::LLNIRSwitchBarFooBase<
      LLNIRSwitchBarFoo>::LLNIRSwitchBarFooBase;
  void runOnOperation() final {
    RewritePatternSet patterns(&getContext());
    patterns.add<LLNIRSwitchBarFooRewriter>(&getContext());
    FrozenRewritePatternSet patternSet(std::move(patterns));
    if (failed(applyPatternsGreedily(getOperation(), patternSet)))
      signalPassFailure();

    ModuleOp module = getOperation();

    for (auto func: module.getOps<func::FuncOp>()) {
      llvm::outs() << "Found FuncOp: " << func.getName() << "\n";
      for (auto &block : func.getBody()) {
        for(auto &op: block) {
          if (auto interfaceOp = dyn_cast<LLNIROp>(op)) {
            llvm::outs() << "Found LLNIROpInterface in op: " << op.getName() << "\n";
          }
          if (op.hasTrait<llnir::LLNIROperatorTrait>()) {
            llvm::outs() << "Found llnir operator trait in op: " << op.getName() << "\n";
          }
        }
      }
    }
    
  }
};
} // namespace
} // namespace mlir::llnir
