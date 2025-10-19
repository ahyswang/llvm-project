add_mlir_dialect(StandaloneOps standalone)
add_mlir_doc(StandaloneDialect StandaloneDialect Standalone/ -gen-dialect-doc)
add_mlir_doc(StandaloneOps StandaloneOps Standalone/ -gen-op-doc)

set(LLVM_TARGET_DEFINITIONS StandalonePasses.td)
mlir_tablegen(StandalonePasses.h.inc --gen-pass-decls)
add_public_tablegen_target(MLIRStandalonePassesIncGen)


set(LLVM_TARGET_DEFINITIONS StandaloneDialect.td)
mlir_tablegen(StandaloneInterfaces.h.inc -gen-op-interface-decls)
mlir_tablegen(StandaloneInterfaces.cpp.inc -gen-op-interface-defs)
add_public_tablegen_target(StandaloneInterfacesIncGen)
add_dependencies(mlir-headers StandaloneInterfacesIncGen)
