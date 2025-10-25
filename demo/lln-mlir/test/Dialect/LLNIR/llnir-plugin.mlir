// UNSUPPORTED: system-windows
// RUN: mlir-opt %s --load-dialect-plugin=%llnir_libs/LLNMLIRPlugin%shlibext --pass-pipeline="builtin.module(llnir-switch-bar-foo)" | FileCheck %s

module {
  // CHECK-LABEL: func @foo()
  func.func @bar() {
    return
  }

  // CHECK-LABEL: func @llnir_types(%arg0: !llnir.custom<"10">)
  func.func @llnir_types(%arg0: !llnir.custom<"10">) {
    return
  }
}
