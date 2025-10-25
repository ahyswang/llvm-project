llvm_canonicalize_cmake_booleans(
        MLIR_ENABLE_BINDINGS_PYTHON
)

configure_lit_site_cfg(
        ${CMAKE_CURRENT_SOURCE_DIR}/lit.site.cfg.py.in
        ${CMAKE_CURRENT_BINARY_DIR}/lit.site.cfg.py
        MAIN_CONFIG
        ${CMAKE_CURRENT_SOURCE_DIR}/lit.cfg.py
)

set(LLNIR_TEST_DEPENDS
        FileCheck count not
        llnmlir-capi-test
        llnmlir-opt
        llnmlir-translate
        )
if(NOT WIN32)
  list(APPEND LLNIR_TEST_DEPENDS LLNMLIRPlugin)
endif()
if(MLIR_ENABLE_BINDINGS_PYTHON)
  list(APPEND LLNIR_TEST_DEPENDS LLNIRPythonModules)
endif()

add_lit_testsuite(check-llnmlir "Running the llnmlir regression tests"
        ${CMAKE_CURRENT_BINARY_DIR}
        DEPENDS ${LLNIR_TEST_DEPENDS}
        )
set_target_properties(check-llnmlir PROPERTIES FOLDER "Tests")

add_lit_testsuites(LLNIR ${CMAKE_CURRENT_SOURCE_DIR} DEPENDS ${LLNIR_TEST_DEPENDS})

add_subdirectory(CAPI)
