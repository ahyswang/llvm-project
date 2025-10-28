# LLN-MLIR

神经网络编译器前端项目.

## 编译LLVM

1. 下载LLVM源码。

```sh
cd ./third_party/
git clone https://github.com/llvm/llvm-project.git
cd ./llvm-project
git checkout 7b6db769c3470d75b0d010f16c50582ec3535dea
```

2. 准备Conda环境。

```sh
conda create -n pymlir python=3.10
conda activate pymlir
python -m pip install --upgrade pip
python -m pip install -r ./mlir/python/requirements.txt
```

3. 编译LLVM源码。

```
./script/build_mlir.sh
```

## 编译LLN-MLIR

1. 修改编译脚本指定LLVM编译路径。
```
PREFIX=$PWD/../../build_debug
BUILD_DIR=$PWD/../../build_debug
```

2. 编译LLN-MLIR源码。
```sh
./script/build.sh
```
