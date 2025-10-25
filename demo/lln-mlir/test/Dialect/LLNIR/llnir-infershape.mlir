// RUN: llnir-opt  --llnir-infer-shapes %s > %t 
// RUN: FileCheck %s < %t

// -----
func.func @test_op_add_infer_shape(%arg0: tensor<2x1x3xf32>, %arg1: tensor<2x1x3xf32>) -> tensor<*xf32> {
    // CHECK: %{{.*}} = "llnir.add"(%{{.*}}, %{{.*}}) : (tensor<2x1x3xf32>, tensor<2x1x3xf32>) -> tensor<2x1x3xf32>
    %res = "llnir.add" (%arg0,%arg0) : (tensor<2x1x3xf32>, tensor<2x1x3xf32>)-> tensor<*xf32>
    return %res : tensor<*xf32>
}
