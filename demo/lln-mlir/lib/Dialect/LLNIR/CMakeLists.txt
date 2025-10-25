file(GLOB OPS_SOURCES "${CMAKE_CURRENT_SOURCE_DIR}/Ops/*.cpp")

add_mlir_dialect_library(MLIRLLNIR
        IR/LLNIRBase.cpp
        IR/LLNIROps.cpp
        Transforms/LLNIRSwitchBarFoo.cpp
        Transforms/LLNIRInferShapes.cpp
        Utils/BaseUtils.cpp
        ${OPS_SOURCES}

        ADDITIONAL_HEADER_DIRS
        ${PROJECT_SOURCE_DIR}/include/LLNIR

        DEPENDS
        MLIRLLNIROpsIncGen
        MLIRLLNIRPassesIncGen
        LLNIRInterfacesIncGen
        MLIRLLNIREnumsIncGen
        MLIRLLNIRAttributesIncGen

        LINK_LIBS PUBLIC
        MLIRIR
        MLIRInferTypeOpInterface
        MLIRFuncDialect
)
