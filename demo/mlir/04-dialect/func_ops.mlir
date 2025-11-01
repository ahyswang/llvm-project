// RUN: mlir-opt %s > %t 
// RUN: FileCheck %s < %t

// CHECK-LABEL: @test_call_noreturn
func.func @test_call_noreturn(%x : tensor<2x4xi32>, %y : tensor<2x4xi32>)
{
    return 
}

// test func.call_indirect

// CHECK-LABEL: @test_call_indirect
func.func @test_call_indirect(%x : tensor<2x4xi32>, %y : tensor<2x4xi32>) -> (tensor<2x4xi32>) 
    attributes { a = "a"} {

    %func = func.constant @test_func_myadd : (tensor<2x4xi32>, tensor<2x4xi32>) -> (tensor<2x4xi32>)
    %res = func.call_indirect %func(%x, %y) : (tensor<2x4xi32>, tensor<2x4xi32>) -> (tensor<2x4xi32>)
    %res1 = func.call @test_func_myadd(%x, %y) : (tensor<2x4xi32>, tensor<2x4xi32>) -> (tensor<2x4xi32>)

    return %res1 : tensor<2x4xi32>
}

// test func.func
  
// CHECK-LABEL: @test_func_myadd
func.func @test_func_myadd(%x : tensor<2x4xi32>, %y : tensor<2x4xi32>) -> (tensor<2x4xi32>) 
    attributes { a = "a"} {
    %res = arith.addi %x, %y: tensor<2x4xi32>
    return %res : tensor<2x4xi32>
}

// test @test_return 
func.func @test_return(%x : tensor<2x4xi32>, %y : tensor<2x4xi32>) -> (tensor<2x4xi32>) 
    attributes { a = "a"} {
    %res = arith.addi %x, %y: tensor<2x4xi32>
    return {a="a"} %res : tensor<2x4xi32>
}
