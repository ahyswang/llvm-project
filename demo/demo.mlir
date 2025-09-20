func.func @test_slice_dynamic(%arg0 : tensor<10x?x2xf32>) -> () {
  // CHECK: %0 = tosa.const_shape  {values = dense<[1, 0, 0]> : tensor<3xindex>}
  // CHECK: %1 = tosa.const_shape  {values = dense<[7, -1, 1]> : tensor<3xindex>}
  // CHECK: %2 = tosa.slice %arg0, %0, %1 : (tensor<10x?x2xf32>, !tosa.shape<3>, !tosa.shape<3>) -> tensor<7x?x1xf32>
  %0 = tosa.const_shape {values = dense<[1, 0, 0]> : tensor<3xindex>} : () -> !tosa.shape<3>
  %1 = tosa.const_shape {values = dense<[7, -1, 1]> : tensor<3xindex>} : () -> !tosa.shape<3>
  %2= tosa.slice %arg0, %0, %1 : (tensor<10x?x2xf32>, !tosa.shape<3>, !tosa.shape<3>) -> tensor<?x?x?xf32>
  return
}