file(GLOB _sources
          IR/*.cpp
          Transforms/*.cpp
    )

add_mlir_library(LLNLLIR
  ${_sources}

  ADDITIONAL_HEADER_DIRS
  ${PROJECT_SOURCE_DIR}/include/LLN/Dialect/LLIR

  DEPENDS
  MLIRLLIRAttrGen
  MLIRLLIROpsIncGen
  MLIRLLIRPassesIncGen
  LLIROpsInterfacesIncGen

  LINK_LIBS PUBLIC
  MLIRIR
  MLIRPass
  MLIRSupport
  MLIRParser
  MLIRFuncDialect
  MLIRQuantDialect
  MLIRRewrite
  MLIRTransforms
)
