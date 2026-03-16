# RUN: not llvm-mc %s -triple=riscv32 -mattr=+xcustomadd 2>&1 \
# RUN:     | FileCheck %s
# RUN: not llvm-mc %s -triple=riscv64 -mattr=+xcustomadd 2>&1 \
# RUN:     | FileCheck %s

# CHECK: error: invalid operand for instruction
custom.add a0, a1, 1

# CHECK: error: too few operands for instruction
custom.add a0, a1
