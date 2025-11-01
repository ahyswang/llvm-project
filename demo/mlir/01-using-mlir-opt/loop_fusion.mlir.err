// RUN: mlir-opt --pass-pipeline="builtin.module(affine-loop-fusion)" %s > %t
// RUN: mlir-opt --pass-pipeline="builtin.module(affine-loop-fusion{fusion-compute-tolerance=0})" %s > %t1
// RUN_NO: FileCheck %s < %t
module {
    func.func @producer_consumer_fusion(%arg0: memref<10xf32>, %arg1: memref<10xf32>) {
        %0 = memref.alloc() : memref<10xf32>
        %1 = memref.alloc() : memref<10xf32>
        %cst = arith.constant 0.0 : f32
        affine.for %arg2 = 0 to 10 {
            affine.store %cst, %0[%arg2] : memref<10xf32>
            affine.store %cst, %1[%arg2] : memref<10xf32>
        }
        affine.for %arg2 = 0 to 10 {
            %2 = affine.load %0[%arg2] : memref<10xf32>
            %3 = arith.addf %2, %2 : f32
            affine.store %3, %0[%arg2] : memref<10xf32>
        }
        affine.for %arg2 = 0 to 10 {
            %2 = affine.load %1[%arg2] : memref<10xf32>
            %3 = arith.addf %2, %2 : f32
            affine.store %3, %1[%arg2] : memref<10xf32>
        }
        return 
    }
}