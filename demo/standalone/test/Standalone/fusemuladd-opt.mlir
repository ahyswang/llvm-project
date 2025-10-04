// RUN: standalone-opt --fuse-mul-add %s -o %t
// RUN: FileCheck %s < %t
module {
    func.func @main(%a:f32, %b:f32, %c:f32) -> f32 {
        // CHECK: %[[t0:.*]] = arith.mulf %[[a:.*]], %[[b:.*]] : f32
        // CHECK: %[[t1:.*]] = arith.mulf %[[a:.*]], %[[c:.*]] : f32
        // CHECK: %[[t2:.*]] = arith.addf %[[t0:.*]], %[[t1:.*]] : f32
        %0 = arith.addf %b, %c : f32
        %1 = arith.mulf %a, %0 : f32

        // CHECK: return %2 : f32
        return %1 : f32
    }
}

//