// RUN: llnmlir-opt %s | llnmlir-opt | FileCheck %s

module {
    // CHECK-LABEL: func @bar()
    func.func @bar() {
        %0 = arith.constant 1 : i32
        // CHECK: %{{.*}} = llnir.foo %{{.*}} : i32
        %res = llnir.foo %0 : i32
        return
    }

    // CHECK-LABEL: func @llnir_types(%arg0: !llnir.custom<"10">)
    func.func @llnir_types(%arg0: !llnir.custom<"10">) {
        return
    }
    
}
