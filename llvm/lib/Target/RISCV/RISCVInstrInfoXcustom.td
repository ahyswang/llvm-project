//===-- RISCVInstrInfoXcustom.td ---------------------------*- tablegen -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file describes the custom vendor extension Xcustomadd, which provides
// a custom addition instruction with the same semantics as the standard ADD.
//
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
// Xcustomadd - Custom Addition Instruction
//===----------------------------------------------------------------------===//

let Predicates = [HasVendorXcustomadd], hasSideEffects = 0,
    mayLoad = 0, mayStore = 0, isCodeGenOnly = 0,
    DecoderNamespace = "Xcustomadd" in {

def CUSTOM_ADD : RVInstR<0b0000000, 0b000, OPC_CUSTOM_0,
                         (outs GPR:$rd), (ins GPR:$rs1, GPR:$rs2),
                         "custom.add", "$rd, $rs1, $rs2">,
                 Sched<[WriteIALU, ReadIALU, ReadIALU]>;

} // Predicates = [HasVendorXcustomadd]
