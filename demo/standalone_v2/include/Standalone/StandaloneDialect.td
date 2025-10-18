//===- StandaloneDialect.td - Standalone dialect -----------*- tablegen -*-===//
//
// This file is licensed under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef STANDALONE_DIALECT
#define STANDALONE_DIALECT

include "mlir/IR/OpBase.td"
include "mlir/Interfaces/InferTypeOpInterface.td"

//===----------------------------------------------------------------------===//
// Standalone dialect definition.
//===----------------------------------------------------------------------===//

def Standalone_Dialect : Dialect {
    let name = "standalone";
    let summary = "A standalone out-of-tree MLIR dialect.";
    let description = [{
        This dialect is an example of an out-of-tree MLIR dialect designed to
        illustrate the basic setup required to develop MLIR-based tools without
        working inside of the LLVM source tree.
    }];
    let cppNamespace = "::mlir::standalone";

    let useDefaultTypePrinterParser = 1;
    let extraClassDeclaration = [{
        void registerTypes();
    }];
}

//===----------------------------------------------------------------------===//
// Base standalone operation definition.
//===----------------------------------------------------------------------===//

class Standalone_Op<string mnemonic, list<Trait> traits = []> :
        Op<Standalone_Dialect, mnemonic, traits>;


//===----------------------------------------------------------------------===//
// Standalone Operator Trait.
//===----------------------------------------------------------------------===//
// Op operands with Standalone shape types must be compile time resolvable
def StandaloneResolvableShapeOperands : NativeOpTrait<"StandaloneResolvableShapeOperands"> {
  let cppNamespace = "mlir::OpTrait::standalone";
}

// Op trait: operator has operands and results with Standalone shape type
def StandaloneShapeOperator : NativeOpTrait<"StandaloneShapeOperator"> {
  let cppNamespace = "mlir::OpTrait::standalone";
}

def StandaloneOpInterface : OpInterface<"StandaloneOp"> {
  let description = [{
    Implemented by ops that correspond to the Tosa specification.
  }];
}

//===----------------------------------------------------------------------===//
// TOSA Operator Class.
//===----------------------------------------------------------------------===//

class Standalone_Opv1<string mnemonic, list<Trait> traits = []> :
    Op<Standalone_Dialect, mnemonic, !listconcat(traits, [
        StandaloneOpInterface,
        DeclareOpInterfaceMethods<InferShapedTypeOpInterface,["inferReturnTypeComponents"]>
        ])> {
}


class Standalone_Opv2<string mnemonic, list<Trait> traits = []> :
    Op<Standalone_Dialect, mnemonic, !listconcat(traits, [StandaloneOpInterface,
    StandaloneResolvableShapeOperands])> {
}

#endif // STANDALONE_DIALECT
