#!/bin/bash 

PREFIX=$PWD/../../build_debug
BUILD_DIR=$PWD/../../build_debug

cmake -B./build \ 
-H./ \
-DMLIR_ENABLE_BINDINGS_PYTHON=ON \
-DMLIR_DIR=$PREFIX/lib/cmake/mlir \
-DLLVM_EXTERNAL_LIT=$BUILD_DIR/bin/llvm-lit \
-DCMAKE_BUILD_TYPE=Debug

cmake --build ./build --target check-llnir -j16