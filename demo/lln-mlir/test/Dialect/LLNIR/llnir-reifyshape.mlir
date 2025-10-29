// RUN: llnmlir-opt  --llnir-infer-shapes --byteir-shape-reification %s > %t 
// RUN: FileCheck %s < %t

// -----
func.func @test_op_matmul_reify_shape(%arg0: tensor<2x?x16xi8>, %arg1: tensor<2x16x32xi8>) -> !shape.shape {
    %0 = "llnir.matmul"(%arg0, %arg1): (tensor<2x?x16xi8>, tensor<2x16x32xi8>)-> tensor<*xi8>
    %1 = shape.shape_of %0 : tensor<*xi8> -> tensor<3xindex>
    %2 = shape.value_as_shape %1 : tensor<3xindex> -> !shape.shape
    return %2 : !shape.shape
}

// CHECK-LABEL: func.func @test_op_matmul_reify_shape
// CHECK-DAG:     %[[C32:.+]] = arith.constant 32 : index
// CHECK-DAG:     %[[C2:.+]] = arith.constant 2 : index
// CHECK-DAG:     %[[C1:.+]] = arith.constant 1 : index
// CHECK-DAG:     %[[V0:.+]] = tensor.dim %arg0, %[[C1]] : tensor<2x?x16xi8>
// CHECK-DAG:     %[[V1:.+]] = tensor.from_elements %[[C2]], %[[V0]], %[[C32]] : tensor<3xindex>
// CHECK-DAG:     %[[V2:.+]] = shape.value_as_shape %[[V1]] : tensor<3xindex> -> !shape.shape
// CHECK-DAG:     return %[[V2]] : !shape.shape