// RUN: standalone-opt %s > %t 
// RUN: FileCheck %s < %t

// -----
func.func @test_op_add(%arg0: tensor<2x1x3xf32>, %arg1: tensor<2x1x3xf32>) -> tensor<2x1x3xf32> {
    // CHECK: %{{.*}} = "standalone.add"(%{{.*}}, %{{.*}}) : (tensor<2x1x3xf32>, tensor<2x1x3xf32>) -> tensor<2x1x3xf32>
    %res = "standalone.add"(%arg0,%arg0) : (tensor<2x1x3xf32>, tensor<2x1x3xf32>)-> tensor<2x1x3xf32>
    return %res : tensor<2x1x3xf32>
}

