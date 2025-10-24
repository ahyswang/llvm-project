file(GLOB OPS_SOURCES "${CMAKE_CURRENT_SOURCE_DIR}/Ops/*.cpp")

add_mlir_dialect_library(MLIRStandalone
        IR/StandaloneBase.cpp
        IR/StandaloneOps.cpp
        Transforms/StandaloneSwitchBarFoo.cpp
        Transforms/StandaloneInferShapes.cpp
        Utils/BaseUtils.cpp
        ${OPS_SOURCES}

        ADDITIONAL_HEADER_DIRS
        ${PROJECT_SOURCE_DIR}/include/Standalone

        DEPENDS
        MLIRStandaloneOpsIncGen
        MLIRStandalonePassesIncGen
        StandaloneInterfacesIncGen
        MLIRStandaloneEnumsIncGen
        MLIRStandaloneAttributesIncGen

        LINK_LIBS PUBLIC
        MLIRIR
        MLIRInferTypeOpInterface
        MLIRFuncDialect
)
