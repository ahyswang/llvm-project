// RUN: standalone-opt -allow-unregistered-dialect %s > %t 
// RUN: FileCheck %s < %t

!quant_type = !quant.uniform<i32:f32, 0.078431375324726104>

func.func @test_op_mul_int8(%arg0: tensor<2x1x3x!quant_type>, %arg1: tensor<2x1x3x!quant_type>) -> tensor<2x1x3x!quant_type> {
    // CHECK: %{{.*}} = "standalone.mul"(%{{.*}}, %{{.*}}) : (tensor<2x1x3x!quant.uniform<i32:f32, 0.078431375324726104>>, tensor<2x1x3x!quant.uniform<i32:f32, 0.078431375324726104>>) -> tensor<2x1x3x!quant.uniform<i32:f32, 0.078431375324726104>>
    %res = "standalone.mul"(%arg0,%arg0) : (tensor<2x1x3x!quant_type>, tensor<2x1x3x!quant_type>)-> tensor<2x1x3x!quant_type>
    return %res : tensor<2x1x3x!quant_type>
}
