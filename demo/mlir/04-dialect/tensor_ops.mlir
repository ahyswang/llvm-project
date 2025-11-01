// RUN: mlir-opt %s > %t 
// RUN: FileCheck %s < %t


// CHECK-LABEL: @test_bitcast
func.func @test_bitcast()  {
    %a = arith.constant dense<[1,2]>: tensor<2xui4>
    %b = tensor.bitcast %a : tensor<2xui4> to tensor<2xi4>
    %c = "tensor.bitcast"(%a) : (tensor<2xui4>) -> tensor<2xi4>
    func.return 
}

// CHECK-LABEL: @test_cast
func.func @test_cast(%arg0:tensor<*xf32>)  {
    // Convert from unknown rank to rank 2 with unknown dimension sizes.
    %2 = "tensor.cast"(%arg0) : (tensor<*xf32>) -> tensor<?x?xf32>

    // Convert to a type with more known dimensions.
    %3 = "tensor.cast"(%2) : (tensor<?x?xf32>) -> tensor<4x?xf32>

    // Discard static dimension and rank information.
    %4 = "tensor.cast"(%3) : (tensor<4x?xf32>) -> tensor<?x?xf32>
    %5 = "tensor.cast"(%4) : (tensor<?x?xf32>) -> tensor<*xf32>

    func.return 
}

// CHECK-LABEL: @test_collapse_shape 
func.func @test_collapse_shape (%arg0:tensor<?x?x?xf32>)  {
    %a = "tensor.collapse_shape"(%arg0) { reassociation = [[0,1],[2]]} : (tensor<?x?x?xf32>) -> tensor<?x?xf32>
    func.return 
}

// CHECK-LABEL: @test_expand_shape 
func.func @test_expand_shape (%arg0:tensor<?x32xf32>, %sz0:index, %sz1:index)  {
    //TODO:
    //%a = "tensor.expand_shape"(%arg0) { reassociation = [[0,1],[2]], static_output_shape = [%sz0, %sz1, 32]} : (tensor<?x32xf32>) -> tensor<?x?x32xf32>
    func.return 
}

// CHECK-LABEL: @test_concat 
func.func @test_concat ()  {

    %0 = "arith.constant"() {value = dense<0.0>:tensor<3x6xf32>} : () -> tensor<3x6xf32>
    %1 = "arith.constant"() {value = dense<0.0>:tensor<3x6xf32>} : () -> tensor<3x6xf32>
    %2 = "arith.constant"() {value = dense<0.0>:tensor<1x6xf32>} : () -> tensor<1x6xf32>

    %a = tensor.concat dim(0) %0,%1,%2: (tensor<3x6xf32>, tensor<3x6xf32>, tensor<1x6xf32>) -> tensor<7x6xf32>
    %b = "tensor.concat" (%0,%1,%2) {dim=0} : (tensor<3x6xf32>, tensor<3x6xf32>, tensor<1x6xf32>) -> tensor<7x6xf32>
    func.return 
}

// CHECK-LABEL: @test_dim 
func.func @test_dim ()  {
    %0 = "arith.constant"() {value = dense<0.0>:tensor<3x6xf32>} : () -> tensor<3x6xf32>
    %c0 ="arith.constant"() {value = 0:index} : () -> index
    %d0 = tensor.dim %0, %c0 : tensor<3x6xf32>
    %d0_1 = "tensor.dim"(%0, %c0) : (tensor<3x6xf32>,index) -> index
    func.return 
}

// CHECK-LABEL: @test_empty 
func.func @test_empty ()  {
    
    %c0 ="arith.constant"() {value = 10:index} : () -> index

    %empty0 = "tensor.empty"(%c0) : (index) -> tensor<2x?xf32>

    func.return 
}


// CHECK-LABEL: @test_extract 
func.func @test_extract ()  {
    %0 = "arith.constant"() {value = dense<0.0>:tensor<3x6xf32>} : () -> tensor<3x6xf32>
    %1 = "arith.constant"() {value = 1:index} : () -> index 
    %2 = "arith.constant"() {value = 2:index} : () -> index
    %a = tensor.extract %0[%1,%2] : tensor<3x6xf32> 
    %b = "tensor.extract"(%0, %1, %2) : (tensor<3x6xf32>, index, index) -> f32

    func.return 
}


// CHECK-LABEL: @test_extract_slice
func.func @test_extract_slice (%arg0:tensor<8x16x4xf32>, %o0:index, %o2:index, %sz1:index, %st1:index)  {
    
    %1 = tensor.extract_slice %arg0[0,0,0][1,16,4][1,1,1] : tensor<8x16x4xf32> to tensor<1x16x4xf32>
    %3 = tensor.extract_slice %arg0[%o0,0,%o2][1,%sz1,4][1,%st1,1] : tensor<8x16x4xf32> to tensor<1x?x4xf32>
    
    func.return 
}

// CHECK-LABEL: @test_extract_slice_2
func.func @test_extract_slice_2 (%arg0:tensor<8x16x4xf32>, %arg1:index, %arg2:index, %arg3:index)  {

    //TODO:
    //%2 = "tensor.extract_slice"(%arg0, %arg1, %arg2, %arg3) { 
    //  static_offsets = array<i64:0, 0, 0>,    
    //  static_sizes = array<i64:1, 16, 4>, 
    //  static_strides = array<i64:1, 1, 1> 
    //} : (tensor<8x16x4xf32>, index, index, index) -> tensor<1x16x4xf32>

    func.return 
}

// CHECK-LABEL: @test_generate
func.func @test_generate (%s:f32, %m:index, %n:index)  {

    %tnsr = tensor.generate %m, %n {
        ^bb0(%i:index, %j:index, %k:index) :
            %elem = arith.constant 10.0 : f32 
        tensor.yield %elem : f32 
    } : tensor<?x3x?xf32>

    func.return 
}


// CHECK-LABEL: @test_splat
func.func @test_splat (%s:f32)  {

    //Example for a statically shaped tensor
    %t = tensor.splat %s : tensor<8x16xf32>
    
    //Example for a tensor containing dynamic dimensions:
    // Broadcasts %s to a 3D dynamically shaped tensor, with %m and %n binding
    // to dimensions 0 and 2 of the resulting tensor, respectively.
    %m = arith.constant 10 : index 
    %n = arith.constant 30 : index 
    %t1 = tensor.splat %s[%m, %n] : tensor<?x20x?xf32>

    %t2 = "tensor.splat"(%s, %m, %n) : (f32, index, index) -> tensor<?x20x?xf32>

    func.return 
}