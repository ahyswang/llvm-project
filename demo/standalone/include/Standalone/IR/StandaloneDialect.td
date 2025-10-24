//===- StandaloneDialect.td - Standalone dialect -----------*- tablegen -*-===//
//
// This file is licensed under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef MLIR_DIALECT_STANDALONE_IR_STANDALONEDIALECT_TD
#define MLIR_DIALECT_STANDALONE_IR_STANDALONEDIALECT_TD

include "mlir/IR/AttrTypeBase.td"
include "mlir/IR/EnumAttr.td"
include "mlir/IR/OpBase.td"

include "mlir/Interfaces/SideEffectInterfaces.td"
include "mlir/Interfaces/InferTypeOpInterface.td"
include "mlir/Interfaces/LoopLikeInterface.td"

//include "Standalone/IR/StandaloneInterfaces.td"

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
    let dependentDialects = ["tensor::TensorDialect", "quant::QuantDialect"];

    let useDefaultTypePrinterParser = 1;
    let hasConstantMaterializer = 1; 
}

//===----------------------------------------------------------------------===//
// Standalone Iterable attributes.
//===----------------------------------------------------------------------===//
// Defined in `section 3. Enumerations` of the Standalone specification.

// Wrapper over base I32EnumAttr to set common fields.
class Standalone_I32Enum<string name, string description, list<I32EnumAttrCase> cases>
     : I32EnumAttr<name, description, cases> {
   let genSpecializedAttr = 0;
   let cppNamespace = "::mlir::standalone";
}

class Standalone_I32EnumAttr<string name, string description, string mnemonic,
                         list<I32EnumAttrCase> cases>
    : EnumAttr<Standalone_Dialect, Standalone_I32Enum<name, description, cases>, mnemonic> {
   let assemblyFormat = "`<` $value `>`";
}

def Standalone_RESIZE_NEAREST_NEIGHBOR          : I32EnumAttrCase<"NEAREST_NEIGHBOR", 1>;
def Standalone_RESIZE_BILINEAR                  : I32EnumAttrCase<"BILINEAR", 2>;

def Standalone_ResizeModeAttr
    : Standalone_I32EnumAttr<"ResizeMode", "Supported resize/upsampling strategies", "resize_mode",
                    [Standalone_RESIZE_NEAREST_NEIGHBOR, Standalone_RESIZE_BILINEAR]>;

def Standalone_NANPROPAGATION_PROPAGATE : I32EnumAttrCase<"PROPAGATE", 1>;
def Standalone_NANPROPAGATION_IGNORE    : I32EnumAttrCase<"IGNORE", 2>;

def Standalone_NanPropagationModeAttr
    : Standalone_I32EnumAttr<"NanPropagationMode", "Supported NaN propagation strategies", "nan_mode",
                    [Standalone_NANPROPAGATION_PROPAGATE, Standalone_NANPROPAGATION_IGNORE]>;

def Standalone_ROUNDING_SINGLE_ROUND    : I32EnumAttrCase<"SINGLE_ROUND", 1>;
def Standalone_ROUNDING_INEXACT_ROUND   : I32EnumAttrCase<"INEXACT_ROUND", 2>;
def Standalone_ROUNDING_DOUBLE_ROUND    : I32EnumAttrCase<"DOUBLE_ROUND", 3>;

def Standalone_RoundingModeAttr
    : Standalone_I32EnumAttr<"RoundingMode", "Supported rounding modes", "rounding_mode",
                    [Standalone_ROUNDING_SINGLE_ROUND, Standalone_ROUNDING_INEXACT_ROUND, Standalone_ROUNDING_DOUBLE_ROUND]>;

//===----------------------------------------------------------------------===//
// Standalone Interfaces.
//===----------------------------------------------------------------------===//

def StandaloneOpInterface : OpInterface<"StandaloneOp"> {
  let description = [{
    Implemented by ops that correspond to the Tosa specification.
  }];
}

//===----------------------------------------------------------------------===//
// Standalone Operator Trait.
//===----------------------------------------------------------------------===//
// Op operands with Standalone shape types must be compile time resolvable
def StandaloneResolvableShapeOperands : NativeOpTrait<"StandaloneResolvableShapeOperands"> {
  let cppNamespace = "mlir::standalone";
}

// Op trait: operator has operands and results with Standalone shape type
def StandaloneShapeOperator : NativeOpTrait<"StandaloneShapeOperator"> {
  let cppNamespace = "mlir::standalone";
}

// Permits broadcasting. Elementwise trait is too strict.
def StandaloneOperatorTrait : NativeOpTrait<"StandaloneOperatorTrait"> {
  let cppNamespace = "mlir::standalone";
}

// Permits broadcasting. Elementwise trait is too strict.
def StandaloneElementwiseOperator : NativeOpTrait<"StandaloneElementwiseOperator"> {
  let cppNamespace = "mlir::standalone";
}

//===----------------------------------------------------------------------===//
// Standalone Operator Class.
//===----------------------------------------------------------------------===//

class Standalone_Op<string mnemonic, list<Trait> traits = []> :
        Op<Standalone_Dialect, mnemonic, !listconcat(traits, [StandaloneOpInterface, StandaloneOperatorTrait])>;

class Standalone_ElementwiseOp<string mnemonic, list<Trait> traits = []> :
    Standalone_Op<mnemonic, !listconcat(traits, [
              DeclareOpInterfaceMethods<InferShapedTypeOpInterface,["inferReturnTypeComponents"]>,
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

#endif // MLIR_DIALECT_STANDALONE_IR_STANDALONEDIALECT_TD
