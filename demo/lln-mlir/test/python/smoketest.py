# RUN: %python %s pybind11 | FileCheck %s
# RUN: %python %s nanobind | FileCheck %s

import sys
from llnmlir.ir import *
from llnmlir.dialects import builtin as builtin_d

if sys.argv[1] == "pybind11":
    from llnmlir.dialects import llnir_pybind11 as llnir_d
elif sys.argv[1] == "nanobind":
    from llnmlir.dialects import llnir_nanobind as llnir_d
else:
    raise ValueError("Expected either pybind11 or nanobind as arguments")


with Context() as ctx:
    llnir_d.register_dialect()
    module = Module.parse(
        """
    %0 = arith.constant 2 : i32
    %1 = llnir.foo %0 : i32
    """
    )
    for op in module.body.operations:
        print(op)
    # CHECK: %[[C:.*]] = arith.constant 2 : i32
    # CHECK: llnir.foo %[[C]] : i32
    print(str(module))
