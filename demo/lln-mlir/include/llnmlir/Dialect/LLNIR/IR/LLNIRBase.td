//===- LLNIRBase.td - LLNIR dialect -----------*- tablegen -*-===//
//
// This file is licensed under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef MLIR_DIALECT_LLNIR_IR_LLNIRBASE_TD
#define MLIR_DIALECT_LLNIR_IR_LLNIRBASE_TD

include "mlir/IR/AttrTypeBase.td"
include "mlir/IR/EnumAttr.td"
include "mlir/IR/OpBase.td"

include "mlir/Interfaces/SideEffectInterfaces.td"
include "mlir/Interfaces/InferTypeOpInterface.td"
include "mlir/Interfaces/LoopLikeInterface.td"

//include "LLNIR/IR/LLNIRInterfaces.td"

//===----------------------------------------------------------------------===//
// LLNIR dialect definition.
//===----------------------------------------------------------------------===//

def LLNIR_Dialect : Dialect {
    let name = "llnir";
    let summary = "A llnir out-of-tree MLIR dialect.";
    let description = [{
        This dialect is an example of an out-of-tree MLIR dialect designed to
        illustrate the basic setup required to develop MLIR-based tools without
        working inside of the LLVM source tree.
    }];
    let cppNamespace = "::mlir::llnir";
    let dependentDialects = ["tensor::TensorDialect", "quant::QuantDialect"];

    let useDefaultTypePrinterParser = 1;
    let hasConstantMaterializer = 1; 
}

//===----------------------------------------------------------------------===//
// LLNIR Iterable attributes.
//===----------------------------------------------------------------------===//
// Defined in `section 3. Enumerations` of the LLNIR specification.

// Wrapper over base I32EnumAttr to set common fields.
class LLNIR_I32Enum<string name, string description, list<I32EnumAttrCase> cases>
     : I32EnumAttr<name, description, cases> {
   let genSpecializedAttr = 0;
   let cppNamespace = "::mlir::llnir";
}

class LLNIR_I32EnumAttr<string name, string description, string mnemonic,
                         list<I32EnumAttrCase> cases>
    : EnumAttr<LLNIR_Dialect, LLNIR_I32Enum<name, description, cases>, mnemonic> {
   let assemblyFormat = "`<` $value `>`";
}

def LLNIR_RESIZE_NEAREST_NEIGHBOR          : I32EnumAttrCase<"NEAREST_NEIGHBOR", 1>;
def LLNIR_RESIZE_BILINEAR                  : I32EnumAttrCase<"BILINEAR", 2>;

def LLNIR_ResizeModeAttr
    : LLNIR_I32EnumAttr<"ResizeMode", "Supported resize/upsampling strategies", "resize_mode",
                    [LLNIR_RESIZE_NEAREST_NEIGHBOR, LLNIR_RESIZE_BILINEAR]>;

def LLNIR_NANPROPAGATION_PROPAGATE : I32EnumAttrCase<"PROPAGATE", 1>;
def LLNIR_NANPROPAGATION_IGNORE    : I32EnumAttrCase<"IGNORE", 2>;

def LLNIR_NanPropagationModeAttr
    : LLNIR_I32EnumAttr<"NanPropagationMode", "Supported NaN propagation strategies", "nan_mode",
                    [LLNIR_NANPROPAGATION_PROPAGATE, LLNIR_NANPROPAGATION_IGNORE]>;

def LLNIR_ROUNDING_SINGLE_ROUND    : I32EnumAttrCase<"SINGLE_ROUND", 1>;
def LLNIR_ROUNDING_INEXACT_ROUND   : I32EnumAttrCase<"INEXACT_ROUND", 2>;
def LLNIR_ROUNDING_DOUBLE_ROUND    : I32EnumAttrCase<"DOUBLE_ROUND", 3>;

def LLNIR_RoundingModeAttr
    : LLNIR_I32EnumAttr<"RoundingMode", "Supported rounding modes", "rounding_mode",
                    [LLNIR_ROUNDING_SINGLE_ROUND, LLNIR_ROUNDING_INEXACT_ROUND, LLNIR_ROUNDING_DOUBLE_ROUND]>;

//===----------------------------------------------------------------------===//
// LLNIR Interfaces.
//===----------------------------------------------------------------------===//

def LLNIROpInterface : OpInterface<"LLNIROp"> {
  let description = [{
    Implemented by ops that correspond to the LLNIR specification.
  }];
  let cppNamespace = "mlir::llnir";
}

//===----------------------------------------------------------------------===//
// LLNIR Operator Trait.
//===----------------------------------------------------------------------===//
// Op operands with LLNIR shape types must be compile time resolvable
def LLNIRResolvableShapeOperands : NativeOpTrait<"LLNIRResolvableShapeOperands"> {
  let cppNamespace = "mlir::llnir";
}

// Op trait: operator has operands and results with LLNIR shape type
def LLNIRShapeOperator : NativeOpTrait<"LLNIRShapeOperator"> {
  let cppNamespace = "mlir::llnir";
}

// Permits broadcasting. Elementwise trait is too strict.
def LLNIROperatorTrait : NativeOpTrait<"LLNIROperatorTrait"> {
  let cppNamespace = "mlir::llnir";
}

// Permits broadcasting. Elementwise trait is too strict.
def LLNIRElementwiseOperator : NativeOpTrait<"LLNIRElementwiseOperator"> {
  let cppNamespace = "mlir::llnir";
}

//===----------------------------------------------------------------------===//
// LLNIR Operator Class.
//===----------------------------------------------------------------------===//

class LLNIR_Op<string mnemonic, list<Trait> traits = []> :
        Op<LLNIR_Dialect, mnemonic, !listconcat(traits, [LLNIROpInterface, LLNIROperatorTrait])>;

class LLNIR_ElementwiseOp<string mnemonic, list<Trait> traits = []> :
    LLNIR_Op<mnemonic, !listconcat(traits, [
              DeclareOpInterfaceMethods<InferShapedTypeOpInterface,["inferReturnTypeComponents"]>,
              LLNIRElementwiseOperator
              ])> {}

class LLNIR_ElementwiseUnaryOp<string mnemonic, list<Trait> traits = []> :
    LLNIR_ElementwiseOp<mnemonic, !listconcat(traits, [
              SameOperandsAndResultShape,
              SameOperandsAndResultElementType])> {}

class LLNIR_InferTensorTypeOp<string mnemonic, list<Trait> traits = []>
    : LLNIR_Op<mnemonic, !listconcat(traits, [InferTensorTypeAdaptor, Pure])> {}

class LLNIR_InferShapedTypeOp<string mnemonic, list<Trait> traits = []>
    : LLNIR_Op<mnemonic, !listconcat(traits, [InferShapedTypeOpAdaptor, Pure])> {}

// The "SameVariadicOperandSize" trait allows us to pass optional arguments
// for multiple zero points in convolution ops.
class LLNIR_ConvOp<string mnemonic, list<Trait> traits = []>
    : LLNIR_InferShapedTypeOp<mnemonic, !listconcat(traits,
      [SameVariadicOperandSize])> {
  let assemblyFormat =
      "operands attr-dict `:` functional-type(operands, results)";
}

#endif // MLIR_DIALECT_LLNIR_IR_LLNIRBASE_TD
