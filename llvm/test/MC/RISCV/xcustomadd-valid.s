# RUN: llvm-mc %s -triple=riscv32 -mattr=+xcustomadd -show-encoding \
# RUN:     | FileCheck -check-prefixes=CHECK-ASM,CHECK-ASM-AND-OBJ %s
# RUN: llvm-mc %s -triple=riscv64 -mattr=+xcustomadd -show-encoding \
# RUN:     | FileCheck -check-prefixes=CHECK-ASM,CHECK-ASM-AND-OBJ %s
# RUN: llvm-mc -filetype=obj -triple=riscv32 -mattr=+xcustomadd < %s \
# RUN:     | llvm-objdump --mattr=+xcustomadd -d -r - \
# RUN:     | FileCheck --check-prefix=CHECK-ASM-AND-OBJ %s
# RUN: llvm-mc -filetype=obj -triple=riscv64 -mattr=+xcustomadd < %s \
# RUN:     | llvm-objdump --mattr=+xcustomadd -d -r - \
# RUN:     | FileCheck --check-prefix=CHECK-ASM-AND-OBJ %s

# CHECK-ASM-AND-OBJ: custom.add zero, zero, zero
# CHECK-ASM: encoding: [0x0b,0x00,0x00,0x00]
custom.add x0, x0, x0

# CHECK-ASM-AND-OBJ: custom.add ra, sp, gp
# CHECK-ASM: encoding: [0x8b,0x00,0x31,0x00]
custom.add x1, x2, x3

# CHECK-ASM-AND-OBJ: custom.add t0, t1, t2
# CHECK-ASM: encoding: [0x8b,0x02,0x73,0x00]
custom.add x5, x6, x7

# CHECK-ASM-AND-OBJ: custom.add a0, a1, a2
# CHECK-ASM: encoding: [0x0b,0x85,0xc5,0x00]
custom.add x10, x11, x12

# CHECK-ASM-AND-OBJ: custom.add s0, s1, s2
# CHECK-ASM: encoding: [0x0b,0x84,0x24,0x01]
custom.add x8, x9, x18
