===========================================================
RISC-V Custom Addition Instruction Extension (Xcustomadd)
===========================================================

.. contents::
   :local:
   :depth: 3

Technical Background
====================

RISC-V ISA Overview
-------------------

RISC-V is an open-standard instruction set architecture (ISA) based on the
Reduced Instruction Set Computer (RISC) principles. Unlike proprietary ISAs,
RISC-V is designed with modularity and extensibility at its core, making it
ideal for both academic research and commercial chip design.

The RISC-V ISA is structured in a hierarchical manner:

- **Base Integer ISA**: RV32I (32-bit) or RV64I (64-bit) providing the
  fundamental integer computation instructions.
- **Standard Extensions**: Optional extensions such as M (Multiply/Divide),
  A (Atomic), F/D (Floating-Point), C (Compressed), V (Vector), etc.
- **Vendor Extensions**: Custom extensions defined by hardware vendors,
  prefixed with ``X`` (e.g., ``XVentanaCondOps``, ``XTHeadBa``).

Standard ADD Instruction
~~~~~~~~~~~~~~~~~~~~~~~~

The standard RISC-V ``ADD`` instruction is an R-type (Register-Register)
instruction with the following encoding:

.. code-block:: text

   31       25 24   20 19   15 14  12 11    7 6      0
   +---------+-------+-------+------+-------+--------+
   | funct7  |  rs2  |  rs1  |funct3|  rd   | opcode |
   +---------+-------+-------+------+-------+--------+
   | 0000000 | xxxxx | xxxxx | 000  | xxxxx | 0110011|
   +---------+-------+-------+------+-------+--------+

- **opcode** ``[6:0]``: ``0110011`` (``OPC_OP``, 0x33) — identifies this as an
  R-type integer register-register operation
- **funct3** ``[14:12]``: ``000`` — identifies the ADD/SUB group
- **funct7** ``[31:25]``: ``0000000`` — distinguishes ADD from SUB (``0100000``)
- **rd** ``[11:7]``: destination register
- **rs1** ``[19:15]``: first source register
- **rs2** ``[24:20]``: second source register

Semantics: ``rd = rs1 + rs2``

RISC-V Custom Opcode Space
~~~~~~~~~~~~~~~~~~~~~~~~~~~

The RISC-V specification reserves four opcode ranges for custom/vendor-specific
extensions, enabling hardware designers to add proprietary instructions without
conflicting with the standard ISA:

.. list-table:: Reserved Custom Opcodes
   :header-rows: 1
   :widths: 20 20 20

   * - Name
     - Opcode [6:0]
     - Hex Value
   * - ``custom-0``
     - ``0001011``
     - ``0x0B``
   * - ``custom-1``
     - ``0101011``
     - ``0x2B``
   * - ``custom-2``
     - ``1011011``
     - ``0x5B``
   * - ``custom-3``
     - ``1111011``
     - ``0x7B``

These opcode spaces allow chip vendors to implement specialized instructions
while maintaining compatibility with the RISC-V ecosystem. Each custom opcode
can accommodate multiple instructions by varying the ``funct3`` and ``funct7``
fields.

LLVM Compiler Infrastructure
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

LLVM is a widely-used open-source compiler infrastructure that provides a
complete toolchain for compiling, linking, assembling, and disassembling code.
The RISC-V backend in LLVM supports:

- **Assembly**: Parsing RISC-V assembly source into internal representation
- **Encoding**: Converting instructions to binary machine code
- **Disassembly**: Decoding binary machine code back to assembly
- **Code Generation**: Compiling high-level language (via LLVM IR) to RISC-V
  machine code
- **Inline Assembly**: Embedding assembly instructions within C/C++ source code

The LLVM RISC-V backend uses TableGen, a domain-specific language, to
declaratively define instruction formats, encodings, and scheduling information.
This approach enables automatic generation of encoder/decoder tables,
instruction selection patterns, and documentation.

Technical Solution
==================

Overview
--------

This extension, named ``Xcustomadd``, implements a custom addition instruction
``custom.add`` that performs the same operation as the standard RISC-V ``ADD``
instruction but uses the ``custom-0`` opcode space (``0x0B``). This serves as a
reference implementation demonstrating how to add a vendor-specific instruction
to the LLVM RISC-V backend.

The ``custom.add`` instruction is a 32-bit R-type instruction with the
following encoding:

.. code-block:: text

   31       25 24   20 19   15 14  12 11    7 6      0
   +---------+-------+-------+------+-------+--------+
   | funct7  |  rs2  |  rs1  |funct3|  rd   | opcode |
   +---------+-------+-------+------+-------+--------+
   | 0000000 | xxxxx | xxxxx | 000  | xxxxx | 0001011|
   +---------+-------+-------+------+-------+--------+

- **opcode** ``[6:0]``: ``0001011`` (``OPC_CUSTOM_0``, 0x0B)
- **funct3** ``[14:12]``: ``000``
- **funct7** ``[31:25]``: ``0000000``
- **rd** ``[11:7]``: destination register (x0-x31)
- **rs1** ``[19:15]``: first source register (x0-x31)
- **rs2** ``[24:20]``: second source register (x0-x31)

Semantics: ``rd = rs1 + rs2`` (identical to standard ADD)

Implementation Details
----------------------

The implementation follows the established LLVM RISC-V vendor extension pattern,
requiring changes to exactly four source files and two new test files.

1. Feature Definition (RISCVFeatures.td)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

A new subtarget feature ``FeatureVendorXcustomadd`` is defined to gate the
custom instruction behind a feature flag. This ensures the instruction is only
available when explicitly enabled.

.. code-block:: text

   def FeatureVendorXcustomadd
       : RISCVExtension<1, 0, "Custom Addition Extension">;
   def HasVendorXcustomadd
       : Predicate<"Subtarget->hasVendorXcustomadd()">,
         AssemblerPredicate<(all_of FeatureVendorXcustomadd),
             "'Xcustomadd' (Custom Addition Extension)">;

- ``RISCVExtension<1, 0, ...>`` declares version 1.0 of the extension.
- ``Predicate`` enables compile-time gating for instruction selection.
- ``AssemblerPredicate`` enables assembly-time gating with a descriptive error
  message when the extension is not enabled.

**File**: ``llvm/lib/Target/RISCV/RISCVFeatures.td``

2. Instruction Definition (RISCVInstrInfoXcustom.td)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

A new TableGen file defines the ``CUSTOM_ADD`` instruction using the standard
R-type format class ``RVInstR``:

.. code-block:: text

   let Predicates = [HasVendorXcustomadd], hasSideEffects = 0,
       mayLoad = 0, mayStore = 0, isCodeGenOnly = 0,
       DecoderNamespace = "Xcustomadd" in {

   def CUSTOM_ADD : RVInstR<0b0000000, 0b000, OPC_CUSTOM_0,
                             (outs GPR:$rd),
                             (ins GPR:$rs1, GPR:$rs2),
                             "custom.add",
                             "$rd, $rs1, $rs2">,
                    Sched<[WriteIALU, ReadIALU, ReadIALU]>;

   } // Predicates = [HasVendorXcustomadd]

Key attributes:

- ``Predicates = [HasVendorXcustomadd]``: Only available when the extension is
  enabled.
- ``hasSideEffects = 0``: The instruction has no observable side effects beyond
  writing to ``rd``.
- ``mayLoad = 0, mayStore = 0``: The instruction does not access memory.
- ``isCodeGenOnly = 0``: The instruction is available in assembly (not just
  compiler-generated code).
- ``DecoderNamespace = "Xcustomadd"``: Places the instruction in its own
  decoder table, preventing conflicts with other extensions that may use the
  same opcode space.
- ``Sched<[WriteIALU, ReadIALU, ReadIALU]>``: Uses the same scheduling model
  as the standard ``ADD`` instruction.
- ``RVInstR<0b0000000, 0b000, OPC_CUSTOM_0, ...>``: Specifies the R-type
  encoding with funct7=0, funct3=0, and the custom-0 opcode.

**File**: ``llvm/lib/Target/RISCV/RISCVInstrInfoXcustom.td`` (new file)

3. Instruction File Inclusion (RISCVInstrInfo.td)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The new TableGen file is included in the main instruction info file alongside
other vendor extensions:

.. code-block:: text

   include "RISCVInstrInfoXcustom.td"

**File**: ``llvm/lib/Target/RISCV/RISCVInstrInfo.td``

4. Disassembler Support (RISCVDisassembler.cpp)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

A decoder table entry is added to the ``DecoderList32`` array in the
disassembler, enabling binary-to-assembly decoding of the custom instruction:

.. code-block:: cpp

   {DecoderTableXcustomadd32,
    {RISCV::FeatureVendorXcustomadd},
    "Xcustomadd"},

The ``DecoderTableXcustomadd32`` is auto-generated by TableGen from the
``DecoderNamespace = "Xcustomadd"`` attribute. The feature predicate ensures
that the decoder only attempts to decode this instruction when the extension
is enabled.

**File**: ``llvm/lib/Target/RISCV/Disassembler/RISCVDisassembler.cpp``

Encoding Examples
-----------------

The following table shows the binary encoding for several ``custom.add``
instruction instances:

.. list-table:: Encoding Examples (Little-Endian Byte Order)
   :header-rows: 1
   :widths: 35 30 35

   * - Assembly
     - Encoding (hex, LE)
     - 32-bit Machine Code
   * - ``custom.add x0, x0, x0``
     - ``0x0b, 0x00, 0x00, 0x00``
     - ``0x0000000B``
   * - ``custom.add x1, x2, x3``
     - ``0x8b, 0x00, 0x31, 0x00``
     - ``0x0031008B``
   * - ``custom.add x5, x6, x7``
     - ``0x8b, 0x02, 0x73, 0x00``
     - ``0x0073028B``
   * - ``custom.add x10, x11, x12``
     - ``0x0b, 0x85, 0xc5, 0x00``
     - ``0x00C5850B``
   * - ``custom.add x8, x9, x18``
     - ``0x0b, 0x84, 0x24, 0x01``
     - ``0x0124840B``

Encoding Derivation Example
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

For ``custom.add x1, x2, x3`` (rd=1, rs1=2, rs2=3):

.. code-block:: text

   Bit field:  funct7  | rs2   | rs1   | funct3 | rd    | opcode
   Binary:     0000000 | 00011 | 00010 | 000    | 00001 | 0001011
   Hex (32b):  0x0031008B
   LE bytes:   [0x8B, 0x00, 0x31, 0x00]

Usage
-----

Assembly
~~~~~~~~

To assemble a file containing ``custom.add`` instructions:

.. code-block:: bash

   # Assemble with encoding output
   llvm-mc -triple=riscv64 -mattr=+xcustomadd -show-encoding input.s

   # Assemble to object file
   llvm-mc -filetype=obj -triple=riscv64 -mattr=+xcustomadd -o output.o input.s

Disassembly
~~~~~~~~~~~

To disassemble an object file containing ``custom.add`` instructions:

.. code-block:: bash

   llvm-objdump --mattr=+xcustomadd -d output.o

Inline Assembly (C/C++)
~~~~~~~~~~~~~~~~~~~~~~~~

The ``custom.add`` instruction can be used in C/C++ source code via GCC-style
inline assembly:

.. code-block:: c

   #include <stdio.h>

   int main() {
       long a = 10, b = 20, result;

       // Use custom.add via inline assembly
       asm volatile ("custom.add %0, %1, %2"
                     : "=r"(result)       // output: rd
                     : "r"(a), "r"(b));   // inputs: rs1, rs2

       printf("custom.add(%ld, %ld) = %ld\n", a, b, result);
       return 0;
   }

Compile with:

.. code-block:: bash

   clang --target=riscv64 -march=rv64i_xcustomadd1p0 -c example.c -o example.o

Testing
-------

The implementation includes two test files that verify correct behavior:

Valid Instruction Tests
~~~~~~~~~~~~~~~~~~~~~~~~

File ``llvm/test/MC/RISCV/xcustomadd-valid.s`` tests:

- Assembly of ``custom.add`` with various register operands
- Correct binary encoding output
- Round-trip assembly → object → disassembly verification
- Both RV32 and RV64 targets

Invalid Instruction Tests
~~~~~~~~~~~~~~~~~~~~~~~~~~

File ``llvm/test/MC/RISCV/xcustomadd-invalid.s`` tests:

- Immediate operands are rejected (only register operands are valid)
- Appropriate error messages are generated

Run the tests with:

.. code-block:: bash

   llvm-lit llvm/test/MC/RISCV/xcustomadd-valid.s
   llvm-lit llvm/test/MC/RISCV/xcustomadd-invalid.s

Implementation File Summary
----------------------------

.. list-table:: Files Changed
   :header-rows: 1
   :widths: 55 10 35

   * - File Path
     - Status
     - Purpose
   * - ``llvm/lib/Target/RISCV/RISCVFeatures.td``
     - Modified
     - Feature and predicate definition
   * - ``llvm/lib/Target/RISCV/RISCVInstrInfoXcustom.td``
     - New
     - Instruction encoding definition
   * - ``llvm/lib/Target/RISCV/RISCVInstrInfo.td``
     - Modified
     - Include new .td file
   * - ``llvm/lib/Target/RISCV/Disassembler/RISCVDisassembler.cpp``
     - Modified
     - Decoder table registration
   * - ``llvm/test/MC/RISCV/xcustomadd-valid.s``
     - New
     - Valid assembly/encoding/disassembly tests
   * - ``llvm/test/MC/RISCV/xcustomadd-invalid.s``
     - New
     - Invalid operand error tests

Expected Results
================

LLVM Toolchain
--------------

With the ``Xcustomadd`` extension enabled, the following capabilities are
available:

1. **Assembly**: The ``llvm-mc`` assembler recognizes ``custom.add rd, rs1, rs2``
   and produces correct binary encoding using the ``custom-0`` opcode space.

2. **Disassembly**: The ``llvm-objdump`` disassembler correctly decodes the
   binary machine code back to ``custom.add rd, rs1, rs2`` assembly syntax.

3. **Inline Assembly**: The Clang compiler supports ``custom.add`` in inline
   assembly blocks within C/C++ source code when the extension is enabled via
   ``-march=rv64i_xcustomadd1p0``.

4. **Feature Gating**: When the extension is not enabled, attempting to use
   ``custom.add`` produces a clear error message:
   ``instruction requires the following: 'Xcustomadd' (Custom Addition Extension)``

5. **Operand Validation**: Invalid operands (e.g., immediates instead of
   registers) are rejected with appropriate error messages.

Expected Assembly Output
~~~~~~~~~~~~~~~~~~~~~~~~~

.. code-block:: text

   $ echo "custom.add x5, x6, x7" | llvm-mc -triple=riscv64 -mattr=+xcustomadd -show-encoding
   custom.add  t0, t1, t2     # encoding: [0x8b,0x02,0x73,0x00]

Expected Disassembly Output
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. code-block:: text

   $ llvm-objdump --mattr=+xcustomadd -d output.o
   00000000 <.text>:
          0: 0073028b     custom.add  t0, t1, t2

QEMU Simulator Support (Future Work)
--------------------------------------

To enable execution-level simulation of the ``custom.add`` instruction, support
should be added to the open-source QEMU RISC-V emulator. The implementation
plan is as follows:

1. Instruction Decoding
~~~~~~~~~~~~~~~~~~~~~~~~

Add a new decoder entry in the QEMU RISC-V translation layer to recognize the
``custom-0`` opcode (``0x0B``) with funct3=0 and funct7=0.

**File**: ``target/riscv/insn32.decode``

.. code-block:: text

   # Xcustomadd extension
   custom_add  0000000 ..... ..... 000 ..... 0001011 @r

This decode pattern specifies:

- Bits [31:25]: ``0000000`` (funct7)
- Bits [24:20]: ``rs2`` (any 5-bit value)
- Bits [19:15]: ``rs1`` (any 5-bit value)
- Bits [14:12]: ``000`` (funct3)
- Bits [11:7]: ``rd`` (any 5-bit value)
- Bits [6:0]: ``0001011`` (opcode = custom-0)

2. Translation to TCG Operations
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Implement the translation function that converts the decoded instruction into
QEMU's Tiny Code Generator (TCG) intermediate representation:

**File**: ``target/riscv/insn_trans/trans_xcustomadd.c.inc``

.. code-block:: c

   static bool trans_custom_add(DisasContext *ctx, arg_custom_add *a)
   {
       /* custom.add rd, rs1, rs2: rd = rs1 + rs2 */
       TCGv dest = dest_gpr(ctx, a->rd);
       TCGv src1 = get_gpr(ctx, a->rs1, EXT_NONE);
       TCGv src2 = get_gpr(ctx, a->rs2, EXT_NONE);

       tcg_gen_add_tl(dest, src1, src2);
       gen_set_gpr(ctx, a->rd, dest);

       return true;
   }

3. Integration
~~~~~~~~~~~~~~~

Include the translation file in QEMU's main RISC-V translation unit:

**File**: ``target/riscv/translate.c``

.. code-block:: c

   #include "insn_trans/trans_xcustomadd.c.inc"

4. Expected QEMU Result
~~~~~~~~~~~~~~~~~~~~~~~~~

After implementing the QEMU changes, the custom instruction will be
executable on the QEMU RISC-V emulator:

.. code-block:: bash

   # Cross-compile C code with custom.add inline assembly
   clang --target=riscv64 -march=rv64i_xcustomadd1p0 -o test test.c

   # Run on QEMU with custom extension enabled
   qemu-riscv64 -cpu rv64,xcustomadd=true ./test
   # Expected output: custom.add(10, 20) = 30

Architecture Diagram
--------------------

The following diagram illustrates the complete data flow from C source code
through the LLVM toolchain to QEMU execution:

.. code-block:: text

   ┌─────────────────────────────────────────────────────────────────────┐
   │                        C Source Code                                │
   │   asm volatile("custom.add %0, %1, %2" : "=r"(c) : "r"(a),"r"(b))│
   └────────────────────────────┬────────────────────────────────────────┘
                                │  Clang Frontend (-march=rv64i_xcustomadd1p0)
                                ▼
   ┌─────────────────────────────────────────────────────────────────────┐
   │                     LLVM Assembler (llvm-mc)                        │
   │   RISCVAsmParser → Parses "custom.add" mnemonic                    │
   │   RISCVInstrInfoXcustom.td → Encoding rules                        │
   │   Predicate: HasVendorXcustomadd                                   │
   └────────────────────────────┬────────────────────────────────────────┘
                                │  Encoding: R-type with OPC_CUSTOM_0
                                ▼
   ┌─────────────────────────────────────────────────────────────────────┐
   │                    Binary Machine Code (.o / ELF)                   │
   │   custom.add x5, x6, x7 → 0x0073028B                              │
   │   Opcode: 0x0B | funct3: 0x0 | funct7: 0x00                       │
   └──────────┬──────────────────────────────────┬──────────────────────┘
              │                                  │
              ▼                                  ▼
   ┌──────────────────────────┐    ┌─────────────────────────────────────┐
   │  Disassembler            │    │  QEMU Emulator (Future)             │
   │  (llvm-objdump)          │    │  insn32.decode → Decode             │
   │  DecoderTableXcustomadd32│    │  trans_custom_add → TCG translate   │
   │  → "custom.add t0,t1,t2" │    │  tcg_gen_add_tl → Execute          │
   └──────────────────────────┘    └─────────────────────────────────────┘

Conclusion
==========

The ``Xcustomadd`` extension demonstrates a complete, production-quality
implementation of a RISC-V vendor extension in the LLVM compiler infrastructure.
The implementation:

- Follows established LLVM RISC-V backend conventions used by all existing
  vendor extensions (XVentanaCondOps, XTHead, XCV, etc.)
- Requires minimal code changes (4 source files modified/created, ~30 lines of
  code)
- Provides full toolchain support: assembly, binary encoding, disassembly, and
  inline assembly
- Includes comprehensive tests for both valid and invalid inputs
- Is gated behind a feature flag, ensuring no impact on existing functionality
- Serves as a reference template for implementing additional custom instructions

This pattern can be extended to implement more complex custom instructions,
including those with immediate operands, memory access, or multi-cycle
execution, by selecting appropriate instruction format classes and scheduling
models.
