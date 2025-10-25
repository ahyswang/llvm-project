include(AddMLIRPython)

# Specifies that all MLIR packages are co-located under the `mlir_llnir`
# top level package (the API has been embedded in a relocatable way).
add_compile_definitions("MLIR_PYTHON_PACKAGE_PREFIX=${MLIR_PYTHON_PACKAGE_PREFIX}.")


################################################################################
# Sources
################################################################################

declare_mlir_python_sources(LLNIRPythonSources)

declare_mlir_dialect_python_bindings(
  ADD_TO_PARENT LLNIRPythonSources
  ROOT_DIR "${CMAKE_CURRENT_SOURCE_DIR}/mlir_llnir"
  TD_FILE dialects/LLNIROps.td
  SOURCES
    dialects/llnir_pybind11.py
    dialects/llnir_nanobind.py
  DIALECT_NAME llnir)


declare_mlir_python_extension(LLNIRPythonSources.Pybind11Extension
  MODULE_NAME _llnirDialectsPybind11
  ADD_TO_PARENT LLNIRPythonSources
  SOURCES
    LLNIRExtensionPybind11.cpp
  PRIVATE_LINK_LIBS
    LLVMSupport
  EMBED_CAPI_LINK_LIBS
    LLNMLIRCAPI
  PYTHON_BINDINGS_LIBRARY pybind11
)

declare_mlir_python_extension(LLNIRPythonSources.NanobindExtension
  MODULE_NAME _llnirDialectsNanobind
  ADD_TO_PARENT LLNIRPythonSources
  SOURCES
    LLNIRExtensionNanobind.cpp
  PRIVATE_LINK_LIBS
    LLVMSupport
  EMBED_CAPI_LINK_LIBS
    LLNMLIRCAPI
  PYTHON_BINDINGS_LIBRARY nanobind
)


################################################################################
# Common CAPI
################################################################################

add_mlir_python_common_capi_library(LLNIRPythonCAPI
  INSTALL_COMPONENT LLNIRPythonModules
  INSTALL_DESTINATION "${MLIR_BINDINGS_PYTHON_INSTALL_PREFIX}/_mlir_libs"
  OUTPUT_DIRECTORY "${MLIR_BINARY_DIR}/${MLIR_BINDINGS_PYTHON_INSTALL_PREFIX}/_mlir_libs"
  RELATIVE_INSTALL_ROOT "../../../.."
  DECLARED_SOURCES
    LLNIRPythonSources
    # TODO: Remove this in favor of showing fine grained registration once
    # available.
    MLIRPythonExtension.RegisterEverything
    MLIRPythonSources.Core
    MLIRPythonSources.Dialects.builtin
)

################################################################################
# Instantiation of all Python modules
################################################################################

add_mlir_python_modules(LLNIRPythonModules
  ROOT_PREFIX "${MLIR_BINARY_DIR}/${MLIR_BINDINGS_PYTHON_INSTALL_PREFIX}"
  INSTALL_PREFIX "${MLIR_BINDINGS_PYTHON_INSTALL_PREFIX}"
  DECLARED_SOURCES
    LLNIRPythonSources
    # TODO: Remove this in favor of showing fine grained registration once
    # available.
    MLIRPythonExtension.RegisterEverything
    MLIRPythonSources.Core
    MLIRPythonSources.Dialects.builtin
  COMMON_CAPI_LINK_LIBS
    LLNIRPythonCAPI
  )
