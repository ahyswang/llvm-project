// RUN: standalone-opt %s | standalone-opt | FileCheck %s

module {
    // CHECK-LABEL: func @bar()
    func.func @bar() {
        %0 = arith.constant 1 : i32
        // CHECK: %{{.*}} = standalone.foo %{{.*}} : i32
        %res = standalone.foo %0 : i32
        return
    }

    // CHECK-LABEL: func @standalone_types(%arg0: !standalone.custom<"10">)
    func.func @standalone_types(%arg0: !standalone.custom<"10">) {
        return
    }

    func.func @test_op_add(%arg0: tensor<2x1x3xf32>, %arg1: tensor<2x1x3xf32>) -> tensor<2x1x3xf32> {
        %res = "standalone.add"(%arg0,%arg0) : (tensor<2x1x3xf32>, tensor<2x1x3xf32>)-> tensor<2x1x3xf32>
        return %res : tensor<2x1x3xf32>
    }

    func.func @test_op_add_infer_shape(%arg0: tensor<2x1x3xf32>, %arg1: tensor<2x1x3xf32>) -> tensor<*xf32> {
        // CHECK: %{{.*}} = "standalone.add"(%{{.*}}, %{{.*}}) : (tensor<2x1x3xf32>, tensor<2x1x3xf32>) -> tensor<2x1x3xf32>
        %res = "standalone.add"(%arg0,%arg0) : (tensor<2x1x3xf32>, tensor<2x1x3xf32>)-> tensor<*xf32>
        return %res : tensor<*xf32>
    }
}
