#ifndef LLNMLIR_CONVERSION_LLNIRTONPU_H
#define LLNMLIR_CONVERSION_LLNIRTONPU_H

//#include "llnmlir/Dialect/LLNIR/Transforms/Passes.h"
#include "mlir/Pass/Pass.h"
#include "mlir/Transforms/DialectConversion.h"

namespace mlir {
   

#define GEN_PASS_DECL_LLNIRTONPU
#include "llnmlir/Conversion/Passes.h.inc"

namespace llnir {

    
    std::unique_ptr<Pass> createLLNIRToNPU(
        const LLNIRToNPUOptions &options = LLNIRToNPUOptions());
    
        
    void populateLLNIRTypeConversion(TypeConverter &converter);

    void populateLLNIRToNPUConversionPatterns(
        const TypeConverter &convert, RewritePatternSet &patterns,
        const LLNIRToNPUOptions &options);
    
}

}

#endif // LLNMLIR_CONVERSION_LLNIRTONPU_H