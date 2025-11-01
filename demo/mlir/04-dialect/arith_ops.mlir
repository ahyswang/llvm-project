// RUN: mlir-opt %s > %t 
// RUN: FileCheck %s < %t


// CHECK-LABEL: @test_constant
func.func @test_constant()  {

    %0 = arith.constant 4.0: f32
    %1 = arith.constant 4: i32
    %2 = arith.constant 4.0: f16
    %3 = arith.constant 4: i8
    %4 = arith.constant 4: i4
    %5 = arith.constant 4: i6

    %100 = "arith.constant"() { value = 4.0:f32} : () -> f32

    %a = arith.constant dense<[1.0,2.0]>: tensor<2xf32>
    %b = "arith.constant"() { value = dense<[1.0, 2.0]>:tensor<2xf32>} : () -> tensor<2xf32>

    func.return 
}

// CHECK-LABEL: @test_add
func.func @test_add() {

    %a = arith.constant 4.0: f32
    %b = arith.constant 4.0: f32
    %c = arith.addf %a, %b: f32

    func.return 
}

// CHECK-LABEL: @test_add_tensor
func.func @test_add_tensor() {

    %a = arith.constant dense<[1.0,2.0]>: tensor<2xf32>
    %b = arith.constant dense<[1.0,2.0]>: tensor<2xf32>
    %c = arith.addf %a, %b: tensor<2xf32>

    func.return 
}