from mlir.ir import Context, Module 

with Context() as ctx:
    Module.parse("builtin.module {}")

from mlir.ir import Context, IntegerAttr, IntegerType
with Context():
    i8 = IntegerType.get_signless(8)
    integer_attr = IntegerAttr.get(i8, 42)
    print(integer_attr)