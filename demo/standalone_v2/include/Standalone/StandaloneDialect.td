//===- StandaloneDialect.td - Standalone dialect -----------*- tablegen -*-===//
//
// This file is licensed under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef STANDALONE_DIALECT
#define STANDALONE_DIALECT

include "mlir/IR/AttrTypeBase.td"
include "mlir/IR/EnumAttr.td"
include "mlir/IR/OpBase.td"

include "mlir/Interfaces/SideEffectInterfaces.td"
include "mlir/Interfaces/InferTypeOpInterface.td"
include "mlir/Interfaces/LoopLikeInterface.td"

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

    let hasConstantMaterializer = 1; 
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

// Permits broadcasting. Elementwise trait is too strict.
def StandaloneOperatorTrait : NativeOpTrait<"StandaloneOperatorTrait"> {
  let cppNamespace = "mlir::OpTrait::standalone";
}

// Permits broadcasting. Elementwise trait is too strict.
def StandaloneElementwiseOperator : NativeOpTrait<"StandaloneElementwiseOperator"> {
  let cppNamespace = "mlir::OpTrait::standalone";
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

class Standalone_ElementwiseOp1111<string mnemonic, list<Trait> traits = []> :
    Standalone_Op<mnemonic, !listconcat(traits, [
              DeclareOpInterfaceMethods<InferShapedTypeOpInterface,["inferReturnTypeComponents"]>,
              ResultsBroadcastableShape,
              StandaloneElementwiseOperator,
              SameOperandsAndResultRank,
              Pure])> {}

class Standalone_ElementwiseOp<string mnemonic, list<Trait> traits = []> :
    Standalone_Op<mnemonic, !listconcat(traits, [
              DeclareOpInterfaceMethods<InferShapedTypeOpInterface,["inferReturnTypeComponents"]>,
              StandaloneOperatorTrait,
              StandaloneElementwiseOperator
              ])> {}

class Standalone_ElementwiseUnaryOp<string mnemonic, list<Trait> traits = []> :
    Standalone_ElementwiseOp<mnemonic, !listconcat(traits, [
              SameOperandsAndResultShape,
              SameOperandsAndResultElementType])> {}

class Standalone_InferTensorTypeOp<string mnemonic, list<Trait> traits = []>
    : Standalone_Op<mnemonic, !listconcat(traits, [InferTensorTypeAdaptor, Pure])> {}

class Standalone_InferShapedTypeOp<string mnemonic, list<Trait> traits = []>
    : Standalone_Op<mnemonic, !listconcat(traits, [InferShapedTypeOpAdaptor, Pure])> {}

// The "SameVariadicOperandSize" trait allows us to pass optional arguments
// for multiple zero points in convolution ops.
class Standalone_ConvOp<string mnemonic, list<Trait> traits = []>
    : Standalone_InferShapedTypeOp<mnemonic, !listconcat(traits,
      [SameVariadicOperandSize])> {
  let assemblyFormat =
      "operands attr-dict `:` functional-type(operands, results)";
}

#endif // STANDALONE_DIALECT
