add_mlir_dialect(LLIROps llir)

set(LLVM_TARGET_DEFINITIONS LLIROps.td)
mlir_tablegen(LLIRAttr.h.inc -gen-attrdef-decls)
mlir_tablegen(LLIRAttr.cpp.inc -gen-attrdef-defs)
add_public_tablegen_target(MLIRLLIRAttrGen)

set(LLVM_TARGET_DEFINITIONS LLIROpsInterfaces.td)
mlir_tablegen(LLIROpsInterfaces.h.inc -gen-op-interface-decls)
mlir_tablegen(LLIROpsInterfaces.cpp.inc -gen-op-interface-defs)
add_public_tablegen_target(LLIROpsInterfacesIncGen)
add_dependencies(mlir-headers LLIROpsInterfacesIncGen)