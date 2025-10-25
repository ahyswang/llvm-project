add_llvm_library(LLNMLIRPlugin
        # BUILDTREE_ONLY is only for testing purposes
        MODULE BUILDTREE_ONLY
        llnmlir-plugin.cpp

        DEPENDS
        MLIRLLNIR
        PLUGIN_TOOL
        mlir-opt

        LINK_LIBS
        MLIRLLNIR
        )
target_include_directories(
        LLNMLIRPlugin
        PRIVATE
        "${LLNMLIR_BINARY_DIR}/include"
)
