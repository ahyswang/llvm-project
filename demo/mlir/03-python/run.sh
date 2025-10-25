#conda activate pymlir

export PYTHONPATH=$PWD/../../build_debug/tools/mlir/python_packages/mlir_core/:$PYTHONPATH
export PATH=/workspace/yswang26/opt/miniforge3/envs/pymlir/bin/:$PATH

python demo.py 