// RUN: mlir-opt %s | FileCheck %s
module {
    // CHECK-LABEL: func @main()
  func.func @main() {
    // CHECK: %[[C:.*]] = arith.constant 42 : i32
    %1 = arith.constant 42 : i32
    return
  }
}
