#!/bin/bash 

PREFIX=$PWD/../../build_debug
BUILD_DIR=$PWD/../../build_debug

mkdir -p build && cd build
cmake -G Ninja .. -DMLIR_DIR=$PREFIX/lib/cmake/mlir -DLLVM_EXTERNAL_LIT=$BUILD_DIR/bin/llvm-lit -DCMAKE_BUILD_TYPE=Debug
cmake --build . --target check-standalone