// RUN: llnmlir-opt  --llnir-infer-shapes %s > %t 
// RUN: FileCheck %s < %t

// -----
func.func @test_op_add_infer_shape(%arg0: tensor<2x1x3xf32>, %arg1: tensor<2x1x3xf32>) -> tensor<*xf32> {
    // CHECK: %{{.*}} = "llnir.add"(%{{.*}}, %{{.*}}) : (tensor<2x1x3xf32>, tensor<2x1x3xf32>) -> tensor<2x1x3xf32>
    %res = "llnir.add" (%arg0,%arg0) : (tensor<2x1x3xf32>, tensor<2x1x3xf32>)-> tensor<*xf32>
    return %res : tensor<*xf32>
}

// -----
// CHECK-LABEL: matmul
func.func @test_op_matmul_infer_shape(%arg0: tensor<2x8x16xi8>, %arg1: tensor<2x16x32xi8>) -> tensor<*xi8> {
    %res = "llnir.matmul"(%arg0, %arg1): (tensor<2x8x16xi8>, tensor<2x16x32xi8>)-> tensor<*xi8>
    return %res : tensor<*xi8>
}