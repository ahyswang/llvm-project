// RUN: llnmlir-opt -pass-pipeline="builtin.module(func.func(llnir-to-npu{prefer-quant=true}))" %s > %t 
// RUN: FileCheck %s < %t


func.func @test_matmul(%arg0: tensor<1x14x19xf32>, %arg1: tensor<1x19x28xf32>) -> tensor<1x14x28xf32> {
%0 = "llnir.matmul" (%arg0, %arg1) : (tensor<1x14x19xf32>, tensor<1x19x28xf32>)  -> tensor<1x14x28xf32>
  return %0 : tensor<1x14x28xf32>
}

// CHECK-LABEL:     func.func @test_matmul
// CHECK-DAG:   %[[CST:.*]] = arith.constant 0.000000e+00 : f32
// CHECK-DAG:   %[[V0:.*]] = tensor.empty() : tensor<1x14x28xf32>
// CHECK-DAG:   %[[V1:.*]] = linalg.fill ins(%[[CST]] : f32) outs(%[[V0]] : tensor<1x14x28xf32>) -> tensor<1x14x28xf32>
// CHECK-DAG:   %[[V2:.*]] = linalg.batch_matmul ins(%arg0, %arg1 : tensor<1x14x19xf32>, tensor<1x19x28xf32>) outs(%[[V1]] : tensor<1x14x28xf32>) -> tensor<1x14x28xf32>
// CHECK-DAG:   return %[[V2]] : tensor<1x14x28xf32>