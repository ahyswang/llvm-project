// RUN: mlir-opt %s > %t 
// RUN: FileCheck %s < %t


// CHECK-LABEL: @test_math
func.func @test_math()  {

    %0 = arith.constant 4.0: f32
    %1 = math.absf %0 {a="a"} : f32
    %2 = "math.absf"(%0){a="a"}: (f32) -> f32

    %a = arith.constant dense<[1.0,2.0]>: tensor<2xf32>
    %b = "arith.constant"() { value = dense<[1.0, 2.0]>:tensor<2xf32>} : () -> tensor<2xf32>
    %c = math.absf %a: tensor<2xf32>

    func.return 
}