add_mlir_conversion_library(MLIRLLNIRToNPU
  LLNIRToNPU.cpp
  LLNIRToNPUPass.cpp

  ADDITIONAL_HEADER_DIRS
  ${MLIR_MAIN_INCLUDE_DIR}/mlir/Dialect/Tosa
  ${MLIR_MAIN_INCLUDE_DIR}/mlir/IR

  DEPENDS
  LLNMLIRConversionPassIncGen

  LINK_LIBS PUBLIC
  MLIRArithDialect
  MLIRDialectUtils
  MLIRIR
  MLIRIndexDialect
  MLIRLinalgDialect
  MLIRLinalgUtils
  MLIRMathDialect
  MLIRPass
  MLIRSupport
  MLIRTensorDialect
  #MLIRTosaDialect
  #MLIRTosaTransforms
  MLIRLLNIR

  MLIRTransforms
  )