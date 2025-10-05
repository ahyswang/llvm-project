
// RUN: standalone-opt %s -o %t
// RUN: FileCheck %s < %t
module {

func.func @test_add_f32(%arg0: tensor<12x6xf32>, %arg1: tensor<12x6xf32>) -> tensor<12x6xf32> {
   // CHECK: %[[t2:.*]] = standalone.add %[[t0:.*]], %[[t1:.*]] : (tensor<12x6xf32>, tensor<12x6xf32>) -> tensor<12x6xf32>
   %out = standalone.add %arg0, %arg1 : (tensor<12x6xf32>, tensor<12x6xf32>) -> tensor<12x6xf32>
   // CHECK: return %[[t2:.*]] : tensor<12x6xf32>
   return %out : tensor<12x6xf32> 
}

}