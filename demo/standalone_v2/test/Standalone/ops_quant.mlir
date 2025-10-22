// RUN: standalone-opt -allow-unregistered-dialect %s > %t 
// RUN: FileCheck %s < %t

func.func @test_op_mul_int8(%arg0: tensor<2x1x3x!quant.uniform<i32:f32, 0.078431375324726104>>, %arg1: tensor<2x1x3x!quant.uniform<i32:f32, 0.078431375324726104>>) -> tensor<2x1x3x!quant.uniform<i32:f32, 0.078431375324726104>> {
    // CHECK: %{{.*}} = "standalone.mul"(%{{.*}}, %{{.*}}) : (tensor<2x1x3x!quant.uniform<i32:f32, 0.078431375324726104>>, tensor<2x1x3x!quant.uniform<i32:f32, 0.078431375324726104>>) -> tensor<2x1x3x!quant.uniform<i32:f32, 0.078431375324726104>>
    %res = "standalone.mul"(%arg0,%arg0) : (tensor<2x1x3x!quant.uniform<i32:f32, 0.078431375324726104>>, tensor<2x1x3x!quant.uniform<i32:f32, 0.078431375324726104>>)-> tensor<2x1x3x!quant.uniform<i32:f32, 0.078431375324726104>>
    return %res : tensor<2x1x3x!quant.uniform<i32:f32, 0.078431375324726104>>
}
