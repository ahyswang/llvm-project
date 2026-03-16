# RUN: not llvm-mc -triple riscv32 -mattr=+xcustomadd < %s 2>&1 \
# RUN:     | FileCheck %s

# CHECK: error: invalid operand for instruction
custom.add x0, x0, 1

# CHECK: error: invalid operand for instruction
custom.add x0, 1, x0
