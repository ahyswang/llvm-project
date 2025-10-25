# RUN: %python %s pybind11 | FileCheck %s
# RUN: %python %s nanobind | FileCheck %s

import sys
from mlir_llnir.ir import *
from mlir_llnir.dialects import builtin as builtin_d

if sys.argv[1] == "pybind11":
    from mlir_llnir.dialects import llnir_pybind11 as llnir_d
elif sys.argv[1] == "nanobind":
    from mlir_llnir.dialects import llnir_nanobind as llnir_d
else:
    raise ValueError("Expected either pybind11 or nanobind as arguments")


with Context():
    llnir_d.register_dialect()
    module = Module.parse(
        """
    %0 = arith.constant 2 : i32
    %1 = llnir.foo %0 : i32
    """
    )
    # CHECK: %[[C:.*]] = arith.constant 2 : i32
    # CHECK: llnir.foo %[[C]] : i32
    print(str(module))
