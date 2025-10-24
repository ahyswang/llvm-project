add_mlir_dialect_library(MLIRStandalone
        IR/StandaloneDialect.cpp
        IR/StandaloneOps.cpp
        Transforms/StandaloneSwitchBarFoo.cpp
        Transforms/StandaloneInferShapes.cpp

        ADDITIONAL_HEADER_DIRS
        ${PROJECT_SOURCE_DIR}/include/Standalone

        DEPENDS
        MLIRStandaloneOpsIncGen
        MLIRStandalonePassesIncGen
        StandaloneInterfacesIncGen
        MLIRStandaloneEnumsIncGen

        LINK_LIBS PUBLIC
        MLIRIR
        MLIRInferTypeOpInterface
        MLIRFuncDialect
        )
