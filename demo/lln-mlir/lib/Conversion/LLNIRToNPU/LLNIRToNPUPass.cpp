#include "llnmlir/Conversion/LLNIRToNPU/LLNIRToNPU.h"

#include "mlir/Dialect/Arith/IR/Arith.h"
#include "mlir/Dialect/Func/IR/FuncOps.h"
#include "mlir/Dialect/Linalg/IR/Linalg.h"
#include "mlir/Dialect/Math/IR/Math.h"
#include "mlir/Dialect/SCF/IR/SCF.h"
#include "mlir/Dialect/Tensor/IR/Tensor.h"
#include "mlir/IR/PatternMatch.h"
#include "mlir/Pass/PassManager.h"
#include "mlir/Transforms/DialectConversion.h"

#include "llnmlir/Dialect/LLNIR/IR/LLNIR.h"
#include "llnmlir/Dialect/LLNIR/Transforms/Passes.h"

namespace mlir {
#define GEN_PASS_DEF_LLNIRTONPU
#include "llnmlir/Conversion/Passes.h.inc"
}

using namespace mlir;

namespace {
    struct LLNIRToNPU
        : public impl::LLNIRToNPUBase<LLNIRToNPU> {
    public:
        LLNIRToNPU(const LLNIRToNPUOptions &options)
            : impl::LLNIRToNPUBase<LLNIRToNPU>(options) {}

        void getDependentDialects(DialectRegistry &registry) const override {
            registry.insert<arith::ArithDialect, linalg::LinalgDialect,
                math::MathDialect, tensor::TensorDialect, scf::SCFDialect>();
        }

        void runOnOperation() override {
            TypeConverter converter;
            llnir::populateLLNIRTypeConversion(converter);

            RewritePatternSet patterns(&getContext());
            ConversionTarget target(getContext());
            target.addLegalDialect<linalg::LinalgDialect, llnir::LLNIRDialect,
                tensor::TensorDialect, scf::SCFDialect>();
            
            // Not every LLNIR op can be legalized to NPU.
            target.addIllegalOp<llnir::MatMulOp>();
            // TODO:
            target.markUnknownOpDynamicallyLegal([](Operation *) { return true; });

            FunctionOpInterface func = getOperation();
            LLNIRToNPUOptions options;
            options.preferQuant = preferQuant;
            llnir::populateLLNIRToNPUConversionPatterns(converter, patterns, options);
            if (failed(applyPartialConversion(func, target, std::move(patterns))))
                signalPassFailure();
        }
    };
} //namespace 

std::unique_ptr<Pass> mlir::llnir::createLLNIRToNPU(const LLNIRToNPUOptions &options) {
    return std::make_unique<LLNIRToNPU>(options);
}