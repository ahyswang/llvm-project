# Here we create a single aggregate shared library with the parts of the CAPI
# that we want to bundle together. Then we link a simple C executable
# against it to demonstrate that it does have the fully self contained
# core MLIR library and our own llnir dialect.
add_mlir_aggregate(LLNMLIRCAPITestLib
  SHARED
  EMBED_LIBS
  MLIRCAPIIR
  # TODO: Remove this in favor of showing fine grained dialect registration
  # (once available).
  MLIRCAPIRegisterEverything
  LLNMLIRCAPI
)

add_llvm_executable(llnmlir-capi-test
  llnmlir-capi-test.c
)
llvm_update_compile_flags(llnmlir-capi-test)
target_link_libraries(llnmlir-capi-test
  PRIVATE LLNMLIRCAPITestLib)
