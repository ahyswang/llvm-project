// RUN: mlir-opt --pass-pipeline="builtin.module(convert-math-to-llvm)" %s > %t
// RUN: FileCheck %s < %t
module {
    func.func @main(%arg0:i32) -> i32{
        // CHECK: %[[C:.*]] = "llvm.intr.ctlz"(%[[C1:.*]]) <{is_zero_poison = false}> : (i32) -> i32
        %0 = math.ctlz %arg0 : i32
        return %0 : i32
    }    
}