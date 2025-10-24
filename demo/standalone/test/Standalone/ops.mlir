// RUN: standalone-opt %s > %t 
// RUN: FileCheck %s < %t

// -----
func.func @test_op_add(%arg0: tensor<2x1x3xf32>, %arg1: tensor<2x1x3xf32>) -> tensor<2x1x3xf32> {
    // CHECK: %{{.*}} = "standalone.add"(%{{.*}}, %{{.*}}) : (tensor<2x1x3xf32>, tensor<2x1x3xf32>) -> tensor<2x1x3xf32>
    %res = "standalone.add"(%arg0,%arg0) : (tensor<2x1x3xf32>, tensor<2x1x3xf32>)-> tensor<2x1x3xf32>
    return %res : tensor<2x1x3xf32>
}

func.func @test_op_add_scaler(%arg0: tensor<1xf32>, %arg1: tensor<1xf32>) -> tensor<1xf32> {
    %res = "standalone.add"(%arg0,%arg0) : (tensor<1xf32>, tensor<1xf32>)-> tensor<1xf32>
    return %res : tensor<1xf32>
}

// -----
func.func @test_op_mul(%arg0: tensor<2x1x3xf32>, %arg1: tensor<2x1x3xf32>) -> tensor<2x1x3xf32> {
    // CHECK: %{{.*}} = "standalone.mul"(%{{.*}}, %{{.*}}) : (tensor<2x1x3xf32>, tensor<2x1x3xf32>) -> tensor<2x1x3xf32>
    %res = "standalone.mul"(%arg0,%arg0) : (tensor<2x1x3xf32>, tensor<2x1x3xf32>)-> tensor<2x1x3xf32>
    return %res : tensor<2x1x3xf32>
}

// -----
// CHECK-LABEL: conv2d
func.func @test_conv2d(%arg0: tensor<1x4x4x4xf32>, %arg1: tensor<8x1x1x4xf32>, %arg2: tensor<8xf32>, %arg3: tensor<1xf32>, %arg4: tensor<1xf32>) -> tensor<1x4x4x8xf32> {
  %0 = standalone.conv2d %arg0, %arg1, %arg2, %arg3, %arg4 {dilation = array<i64: 1, 1>, pad = array<i64: 0, 0, 0, 0>, stride = array<i64: 1, 1>, local_bound = true} : (tensor<1x4x4x4xf32>, tensor<8x1x1x4xf32>, tensor<8xf32>, tensor<1xf32>, tensor<1xf32>) -> tensor<1x4x4x8xf32>
  return %0 : tensor<1x4x4x8xf32>
}

// -----
func.func @test_op_and(%arg0: tensor<2x8xi8>, %arg1: tensor<2x8xi8>) -> tensor<2x8xi8> {
    %res = "standalone.bitwise_and"(%arg0, %arg1) : (tensor<2x8xi8>, tensor<2x8xi8>)-> tensor<2x8xi8>
    return %res : tensor<2x8xi8>
}

// -----
func.func @test_op_or(%arg0: tensor<2x8xi8>, %arg1: tensor<2x8xi8>) -> tensor<2x8xi8> {
    %res = "standalone.bitwise_or"(%arg0, %arg1) : (tensor<2x8xi8>, tensor<2x8xi8>)-> tensor<2x8xi8>
    return %res : tensor<2x8xi8>
}

// -----
func.func @test_op_xor(%arg0: tensor<2x8xi8>, %arg1: tensor<2x8xi8>) -> tensor<2x8xi8> {
    %res = "standalone.bitwise_xor"(%arg0, %arg1) : (tensor<2x8xi8>, tensor<2x8xi8>)-> tensor<2x8xi8>
    return %res : tensor<2x8xi8>
}

// -----
func.func @test_op_not(%arg0: tensor<2x8xi8>, %arg1: tensor<2x8xi8>) -> tensor<2x8xi8> {
    %res = "standalone.bitwise_not"(%arg0) : (tensor<2x8xi8>)-> tensor<2x8xi8>
    return %res : tensor<2x8xi8>
}