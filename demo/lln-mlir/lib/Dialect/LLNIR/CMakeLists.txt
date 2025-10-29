file(GLOB OPS_SOURCES "${CMAKE_CURRENT_SOURCE_DIR}/Ops/*.cpp")
file(GLOB CANONICALIZE_SOURCES "${CMAKE_CURRENT_SOURCE_DIR}/Canonicalize/*.cpp")
file(GLOB REGISTER_SOURCES "${CMAKE_CURRENT_SOURCE_DIR}/Register/*.cpp")
file(GLOB Analysis_SOURCES "${CMAKE_CURRENT_SOURCE_DIR}/../../Analysis/*.cpp")

add_mlir_dialect_library(MLIRLLNIR
        IR/LLNIRBase.cpp
        IR/LLNIROps.cpp
        Transforms/LLNIRSwitchBarFoo.cpp
        Transforms/LLNIRInferShapes.cpp
        Transforms/ShapeReification.cpp
        Utils/BaseUtils.cpp
        Utils/ShapeInferUtil.cpp
        ${OPS_SOURCES}
        ${CANONICALIZE_SOURCES}
        ${REGISTER_SOURCES}
        ${Analysis_SOURCES}

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
