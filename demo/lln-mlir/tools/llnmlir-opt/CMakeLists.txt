set(LIBS
    MLIRArithDialect
    MLIROptLib
    MLIRRegisterAllDialects
    MLIRRegisterAllPasses
    MLIRLLNIR
  )
add_llvm_executable(llnmlir-opt llnmlir-opt.cpp)

llvm_update_compile_flags(llnmlir-opt)
target_link_libraries(llnmlir-opt PRIVATE ${LIBS})

mlir_check_all_link_libraries(llnmlir-opt)
