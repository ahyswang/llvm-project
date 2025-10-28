#ifndef LLNMLIR_CONVERSION_PASSES_H
#define LLNMLIR_CONVERSION_PASSES_H

#include "llnmlir/Conversion/LLNIRToNPU/LLNIRToNPU.h"

namespace mlir {

/// Generate the code for registering conversion passes.
#define GEN_PASS_REGISTRATION
#include "llnmlir/Conversion/Passes.h.inc"

} // namespace mlir

#endif // MLIR_CONVERSION_PASSES_H