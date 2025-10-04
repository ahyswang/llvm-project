module {
  
  func.func @mla(%a: tensor<2x3xf32>, %b: tensor<2x3xf32>, %c: tensor<2x3xf32>) -> tensor<2x3xf32> {
    %0 = arith.mulf %a, %b
    %1 = arith.addf %0, %c
    return %1 : tensor<2x3xf32>
  }
  
  func.func @main() {
    %cst0 = arith.constant dense<1.000000e+00> : tensor<2x3xf32>
    %cst1 = arith.constant dense<1.000000e+00> : tensor<2x3xf32>
    %0 = func.call @mla(%cst0, %cst1, %cst0) : (tensor<2x3xf32>, tensor<2x3xf32>, tensor<2x3xf32>) -> tensor<2x3xf32>
    return
  }
}