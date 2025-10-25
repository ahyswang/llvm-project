# RUN: %python %s pybind11 | FileCheck %s
# RUN: %python %s nanobind | FileCheck %s

import sys
import numpy as np 
from llnmlir.ir import *
from llnmlir.dialects import builtin as builtin_d

if sys.argv[1] == "pybind11":
    from llnmlir.dialects import llnir_pybind11 as llnir_d
elif sys.argv[1] == "nanobind":
    from llnmlir.dialects import llnir_nanobind as llnir_d
else:
    raise ValueError("Expected either pybind11 or nanobind as arguments")

def test_module():

    with Context() as ctx:
        llnir_d.register_dialect()
        module = Module.create(loc=Location.unknown())
        with InsertionPoint(module.body):
            # Create an i8 type and a tensor type
            i8 = IntegerType.get_signless(8)
            i8_tensor = RankedTensorType.get([4], i8, loc=Location.unknown())
            # Create a DenseElementsAttr
            value = DenseElementsAttr.get(
                np.array([1, 2, 3, 4], dtype=np.int8),
                type=RankedTensorType.get([4], IntegerType.get_signless(8, context=ctx), loc=Location.unknown()),
            )
            # Create a constant operation
            const_op = llnir_d.ConstOp(
                values=value,
                results=[i8_tensor],
                loc=Location.unknown(),
            )

            # Create an add operation
            add_op = llnir_d.AddOp(
                input1=const_op.results[0], 
                input2=const_op.results[0],
                output=i8_tensor,
                loc=Location.name("Add"),
            )
        
        # Print the module with location information
        print("Result of module:\n")
        module.operation.print(print_generic_op_form=True)

if __name__ == "__main__":
    test_module()