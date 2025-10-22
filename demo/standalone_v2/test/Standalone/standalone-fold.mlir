// RUN: standalone-opt  --standalone-infer-shapes --canonicalize %s > %t 
// RUN: FileCheck %s < %t

// -----
// CHECK-LABEL: test_add_const
func.func @test_add_const(%arg0: tensor<2x3xf32>, %arg1: tensor<2x3xf32>) -> tensor<2x3xf32> {
  // CHECK: %{{.*}} = "standalone.const"() <{values = dense<2.000000e+00> : tensor<2x3xf32>}> : () -> tensor<2x3xf32>
  %cst0 = arith.constant dense<1.000000e+00> : tensor<2x3xf32>
  %cst1 = arith.constant dense<1.000000e+00> : tensor<2x3xf32>
  %0 = "standalone.add"(%cst0, %cst1) : (tensor<2x3xf32>, tensor<2x3xf32>) -> tensor<2x3xf32>
  return %0 : tensor<2x3xf32>
}

// CHECK-LABEL: test_add_standalone_const
func.func @test_add_standalone_const(%arg0: tensor<2x3xf32>, %arg1: tensor<2x3xf32>) -> tensor<2x3xf32> {
  // CHECK: %{{.*}} = "standalone.const"() <{values = dense<2.000000e+00> : tensor<2x3xf32>}> : () -> tensor<2x3xf32>
  %cst0 = "standalone.const"() {values = dense<1.000000e+00> : tensor<2x3xf32>} : () -> tensor<2x3xf32>
  %cst1 = "standalone.const"() {values = dense<1.000000e+00> : tensor<2x3xf32>} : () -> tensor<2x3xf32>
  %0 = "standalone.add"(%cst0, %cst1) : (tensor<2x3xf32>, tensor<2x3xf32>) -> tensor<2x3xf32>
  return %0 : tensor<2x3xf32>
}

// CHECK-LABEL: test_mul_standalone_const
func.func @test_mul_standalone_const(%arg0: tensor<2x3xf32>, %arg1: tensor<2x3xf32>) -> tensor<2x3xf32> {
  // CHECK: %{{.*}} = "standalone.const"() <{values = dense<1.000000e+00> : tensor<2x3xf32>}> : () -> tensor<2x3xf32>
  %cst0 = "standalone.const"() {values = dense<1.000000e+00> : tensor<2x3xf32>} : () -> tensor<2x3xf32>
  %cst1 = "standalone.const"() {values = dense<1.000000e+00> : tensor<2x3xf32>} : () -> tensor<2x3xf32>
  %0 = "standalone.mul"(%cst0, %cst1) : (tensor<2x3xf32>, tensor<2x3xf32>) -> tensor<2x3xf32>
  return %0 : tensor<2x3xf32>
}