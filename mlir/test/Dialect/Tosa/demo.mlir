// RUN: mlir-opt %s --verify-each | mlir-opt | FileCheck %s
// RUN: mlir-opt %s --mlir-print-op-generic | mlir-opt | FileCheck %s

// -----
// CHECK-LABEL: conv2d
func.func @test_conv2d(%arg0: tensor<1x4x4x4xf32>, %arg1: tensor<8x1x1x4xf32>, %arg2: tensor<8xf32>, %arg3: tensor<1xf32>, %arg4: tensor<1xf32>) -> tensor<1x4x4x8xf32> {
  %0 = tosa.conv2d %arg0, %arg1, %arg2, %arg3, %arg4 {acc_type = f32, dilation = array<i64: 1, 1>, pad = array<i64: 0, 0, 0, 0>, stride = array<i64: 1, 1>, local_bound = true} : (tensor<1x4x4x4xf32>, tensor<8x1x1x4xf32>, tensor<8xf32>, tensor<1xf32>, tensor<1xf32>) -> tensor<1x4x4x8xf32>
  return %0 : tensor<1x4x4x8xf32>
}




// -----
// CHECK-LABEL: add
func.func @test_add(%arg0: tensor<13x21x1xf32>, %arg1: tensor<13x21x3xf32>) -> tensor<13x21x3xf32> {
  %0 = tosa.add %arg0, %arg1 : (tensor<13x21x1xf32>, tensor<13x21x3xf32>) -> tensor<13x21x3xf32>
  return %0 : tensor<13x21x3xf32>
}

//!input_calibrated = !quant.calibrated<f32<-1.0:1.0>>
!input_calibrated = !quant.uniform<u32:f32, 2.000000e+02>

// -----
// CHECK-LABEL: add
func.func @test_add_calibrated(%arg0: tensor<13x21x1x!input_calibrated>, %arg1: tensor<13x21x3x!input_calibrated>) -> tensor<13x21x3x!input_calibrated> {
  %0 = tosa.add %arg0, %arg1 : (tensor<13x21x1x!input_calibrated>, tensor<13x21x3x!input_calibrated>) -> tensor<13x21x3x!input_calibrated>
  return %0 : tensor<13x21x3x!input_calibrated>
}

// -----
// Storage type: u32
// CHECK: !quant.uniform<u32:f32, 2.000000e+02>
!qalias = !quant.uniform<u32:f32, 2.0e+2>
func.func @parse() -> !qalias {
  %0 = "foo"() : () -> !qalias
  return %0 : !qalias
}