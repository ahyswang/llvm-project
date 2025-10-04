// RUN: mlir-opt %s --convert-arith-to-llvm --convert-func-to-llvm | mlir-translate --mlir-to-llvmir > %t
module {
   func.func @main() {
    %1 = arith.constant 42 : i32
    return
  }
}