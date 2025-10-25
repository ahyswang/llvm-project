// RUN: llnmlir-opt  --llnir-infer-shapes --canonicalize %s > %t 
// RUN: FileCheck %s < %t

// -----
// CHECK-LABEL: test_add_const
func.func @test_add_const(%arg0: tensor<2x3xf32>, %arg1: tensor<2x3xf32>) -> tensor<2x3xf32> {
  // CHECK: %{{.*}} = "llnir.const"() <{values = dense<2.000000e+00> : tensor<2x3xf32>}> : () -> tensor<2x3xf32>
  %cst0 = arith.constant dense<1.000000e+00> : tensor<2x3xf32>
  %cst1 = arith.constant dense<1.000000e+00> : tensor<2x3xf32>
  %0 = "llnir.add"(%cst0, %cst1) : (tensor<2x3xf32>, tensor<2x3xf32>) -> tensor<2x3xf32>
  return %0 : tensor<2x3xf32>
}

// CHECK-LABEL: test_add_llnir_const
func.func @test_add_llnir_const(%arg0: tensor<2x3xf32>, %arg1: tensor<2x3xf32>) -> tensor<2x3xf32> {
  // CHECK: %{{.*}} = "llnir.const"() <{values = dense<2.000000e+00> : tensor<2x3xf32>}> : () -> tensor<2x3xf32>
  %cst0 = "llnir.const"() {values = dense<1.000000e+00> : tensor<2x3xf32>} : () -> tensor<2x3xf32>
  %cst1 = "llnir.const"() {values = dense<1.000000e+00> : tensor<2x3xf32>} : () -> tensor<2x3xf32>
  %0 = "llnir.add"(%cst0, %cst1) : (tensor<2x3xf32>, tensor<2x3xf32>) -> tensor<2x3xf32>
  return %0 : tensor<2x3xf32>
}

// CHECK-LABEL: test_mul_llnir_const
func.func @test_mul_llnir_const(%arg0: tensor<2x3xf32>, %arg1: tensor<2x3xf32>) -> tensor<2x3xf32> {
  // CHECK: %{{.*}} = "llnir.const"() <{values = dense<1.000000e+00> : tensor<2x3xf32>}> : () -> tensor<2x3xf32>
  %cst0 = "llnir.const"() {values = dense<1.000000e+00> : tensor<2x3xf32>} : () -> tensor<2x3xf32>
  %cst1 = "llnir.const"() {values = dense<1.000000e+00> : tensor<2x3xf32>} : () -> tensor<2x3xf32>
  %0 = "llnir.mul"(%cst0, %cst1) : (tensor<2x3xf32>, tensor<2x3xf32>) -> tensor<2x3xf32>
  return %0 : tensor<2x3xf32>
}