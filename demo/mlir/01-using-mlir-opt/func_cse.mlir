// RUN: mlir-opt --pass-pipeline="builtin.module(builtin.module(func.func(cse,canonicalize), convert-to-llvm))" --debug --mlir-print-ir-after-all %s -o %t > %t1 2>&1
module {
    module {
        func.func @func1(%arg0: i32) -> i32 {
        %0 = arith.addi %arg0, %arg0 : i32
        %1 = arith.addi %arg0, %arg0 : i32
        %2 = arith.addi %0, %1 : i32
        func.return %2 : i32
        }
    }
    gpu.module @gpu_module {
        gpu.func @func2(%arg0: i32) -> i32 {
        %0 = arith.addi %arg0, %arg0 : i32
        %1 = arith.addi %arg0, %arg0 : i32
        %2 = arith.addi %0, %1 : i32
        gpu.return %2 : i32
        }
    }
}
