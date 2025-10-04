#!/bin/bash 

BUILD_DIR=../../build_debug/
MLIR_OPT=$BUILD_DIR/bin/mlir-opt
MLIR_TRANSLATE=$BUILD_DIR/bin/mlir-translate
MLIR_CPU_RUNNER=$BUILD_DIR/bin/mlir-runner
LLC=$BUILD_DIR/bin/llc
CLANG=$BUILD_DIR/bin/clang
OPT_FLAG=-O0

MLIR_RUNNER_UTILS=$BUILD_DIR/lib/libmlir_runner_utils.so
MLIR_C_RUNNER_UTILS=$BUILD_DIR/lib/libmlir_c_runner_utils.so
MTRIPLE=x86_64-unknown-linux-gnu


# opt 
$MLIR_OPT --tosa-infer-shapes demo_myadd.mlir -o demo_opt.mlir

# opt
$MLIR_OPT demo_opt.mlir \
  -pass-pipeline='builtin.module(
      func.func(tosa-to-linalg,tosa-to-arith,tosa-to-tensor),
      one-shot-bufferize{bufferize-function-boundaries}, 
      convert-linalg-to-loops, 
      convert-scf-to-cf,
      convert-math-to-llvm,
      convert-arith-to-llvm,
      convert-func-to-llvm,
      convert-cf-to-llvm,
      finalize-memref-to-llvm,
     reconcile-unrealized-casts)' \
  -o demo_llvm.mlir

# run
$MLIR_TRANSLATE -mlir-to-llvmir demo_llvm.mlir -o out.ll
$LLC out.ll -relocation-model=pic -filetype=obj -o out.o
$CLANG out.o $MLIR_RUNNER_UTILS $MLIR_C_RUNNER_UTILS -o demo.out 
export LD_LIBRARY_PATH=$PWD/$BUILD_DIR/lib/
./demo.out 

# run
${MLIR_CPU_RUNNER} ${OPT_FLAG} -e main -entry-point-result=void \
		-shared-libs=${MLIR_RUNNER_UTILS} -shared-libs=${MLIR_C_RUNNER_UTILS} demo_llvm.mlir