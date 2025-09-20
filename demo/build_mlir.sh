mkdir $PWD/build
cd $PWD/build

cmake -G Ninja ../llvm \
   -DLLVM_ENABLE_PROJECTS="mlir;clang;openmp;lldb" \
   -DLLVM_TARGETS_TO_BUILD="host" \
   -DCMAKE_BUILD_TYPE=Release \
   -DLLVM_ENABLE_ASSERTIONS=ON \
   -DLLVM_ENABLE_RTTI=ON \
   -DENABLE_LIBOMPTARGET=OFF \
   -DLLVM_ENABLE_LIBEDIT=OFF \
   -DCMAKE_INSTALL_PREFIX=/workspace/yswang26/opt/llvm

cmake --build . -- ${MAKEFLAGS}
cmake --build . --target check-mlir
cmake --build . --target lldb-dap
cmake --build . --target install