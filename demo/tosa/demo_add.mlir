

func.func @test_myadd(%arg0 : tensor<4xf32>, %arg1 : tensor<4xf32>) -> tensor<4xf32> {
  %0 = tosa.add %arg0, %arg1 : (tensor<4xf32>, tensor<4xf32>) -> tensor<4xf32>
  return %0 :  tensor<4xf32>
}

func.func @test_myadd_infer_shape(%arg0 : tensor<4xi8>, %arg1 : tensor<1xi8>) -> tensor<?xi8> {
  %0 = tosa.add %arg0, %arg1 : (tensor<4xi8>, tensor<1xi8>) -> tensor<?xi8>
  return %0 : tensor<?xi8>
}

func.func @main() -> () {

  %0 = "tosa.const"() {values = dense<[0.0, 1.0, 2.0, 3.0]> : tensor<4xf32>} : () -> tensor<4xf32>
  %1 = "tosa.const"() {values = dense<[0.0, 1.0, 2.0, 3.0]> : tensor<4xf32>} : () -> tensor<4xf32>
  %2 = func.call @test_myadd(%0, %1) : ( tensor<4xf32>,  tensor<4xf32>) ->  tensor<4xf32>

  %tensor_unranked = tensor.cast %2 : tensor<4xf32> to tensor<*xf32>

  call @printMemrefF32(%tensor_unranked) : (tensor<*xf32>) -> ()

  return 
}

func.func private @printMemrefF32(%ptr : tensor<*xf32>)

