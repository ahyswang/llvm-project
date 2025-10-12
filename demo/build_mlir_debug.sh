# conda create -n pymlir python=3.10
# conda activate pymlir
# python -m pip install --upgrade pip
# python -m pip install -r ./mlir/python/requirements.txt

mkdir -p $PWD/build_debug
cd $PWD/build_debug

cmake -G Ninja ../llvm \
   -DLLVM_ENABLE_PROJECTS="mlir;clang;openmp" \
   -DLLVM_TARGETS_TO_BUILD="host" \
   -DCMAKE_BUILD_TYPE=Debug \
   -DLLVM_ENABLE_ASSERTIONS=ON \
   -DLLVM_ENABLE_RTTI=ON \
   -DENABLE_LIBOMPTARGET=OFF \
   -DLLVM_ENABLE_LIBEDIT=OFF \
   -DLLVM_ENABLE_BINDINGS=ON \
   -DMLIR_ENABLE_BINDINGS_PYTHON=ON \
   -DPython3_EXECUTABLE=$(which python3) 

# cmake --build . -- ${MAKEFLAGS}
# cmake --build . --target check-mlir
cmake --build . --target mlir-opt
cmake --build . --target check-mlir-python
# ninja -j16 mlir-opt