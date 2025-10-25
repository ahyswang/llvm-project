//===-- LLNIRTypesBase.td - LLNIR type definitions -----------*- tablegen -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file defines the type definitions for the LLNIR dialect.
//
//===----------------------------------------------------------------------===//

#ifndef MLIR_DIALECT_LLNIR_IR_LLNIRTYPES_TD
#define MLIR_DIALECT_LLNIR_IR_LLNIRTYPES_TD

include "mlir/IR/AttrTypeBase.td"
include "mlir/IR/OpBase.td"

include "llnmlir/Dialect/LLNIR/IR/LLNIRBase.td"

//===----------------------------------------------------------------------===//
// LLNIR Type Definitions.
//===----------------------------------------------------------------------===//

// The base class of a quantized type.
// Param tuple is: [bitwidth, zeropt, smantissa, sexp, low_end, high_end].
// Where low and high ends are 0,255 when unsigned, -128,127 when signed, for
// the 8-bit case.
class LLNIR_QuantizedType<string n, list<int> params, bit signed>
  : Type<And<[CPred<"::llvm::isa<mlir::quant::QuantizedType>($_self)">,
              CPred<"::llvm::cast<mlir::quant::QuantizedType>($_self)" #
                    ".getStorageTypeIntegralWidth() == " # !head(params)>]>,
    "Q" # !if (signed, "int", "uint") # !head(params) # " type"> {
  string name = n;
  string asTraitArgsStr = !interleave(params, ", ") #
                          !if(signed, ", true", ", false");
}

//===----------------------------------------------------------------------===//
// Non-Quantized Signed Integer Types.
// Used to express accumulator results or compare results.
//===----------------------------------------------------------------------===//

def LLNIR_Int4 : I<4>;
def LLNIR_Int8 : I<8>;
def LLNIR_Int16 : I<16>;
def LLNIR_Int32 : I<32>;
def LLNIR_Int64 : I<64>;

// The LLNIR dialect allows more types than the LLNIR standard to allow for
// experimentation. For historical reasons, signless is used in the place of
// signed.
// The LLNIRValidation pass can be used to check for standard conformance.
def LLNIR_Int : AnyTypeOf<[AnyUnsignedInteger,
                          AnySignlessInteger]>;

def LLNIR_Int32Or64 : AnyTypeOf<[LLNIR_Int32,
                                LLNIR_Int64]>;

def LLNIR_Int16Or32 : AnyTypeOf<[LLNIR_Int16,
                                LLNIR_Int32]>;

//===----------------------------------------------------------------------===//
// Quantized Integer Types.
// Datatype for network feature map or weight content.
//===----------------------------------------------------------------------===//
//===----------------------------------------------------------------------===//
// Name    Symmetry   Grouping                Sign
//===----------------------------------------------------------------------===//
// uint8 : asymmetric per tensor ,            unsigned
// int4  : symmetric  per channel,            signed
// int8  : symmetric  per tensor/per channel, signed
// int16 : symmetric  per tensor,             signed
//===----------------------------------------------------------------------===//
def LLNIR_QuantizedInt : AnyTypeOf<[LLNIR_QuantizedType<"uint8", [8], 0>,
                                   LLNIR_QuantizedType<"int4", [4, 0], 1>,
                                   LLNIR_QuantizedType<"int8", [8, 0], 1>,
                                   LLNIR_QuantizedType<"int16", [16, 0], 1>,
                                   LLNIR_QuantizedType<"int32", [32, 0], 1>]>;

//===----------------------------------------------------------------------===//
// Multi-category types.
//===----------------------------------------------------------------------===//
def LLNIR_AnyNumber : AnyTypeOf<[LLNIR_Int, LLNIR_QuantizedInt, AnyFloat],
                                "number">;

//===----------------------------------------------------------------------===//
// LLNIR Tensor Conformance
//===----------------------------------------------------------------------===//

def HasNo0Dimensions : And<[
    IsRankedTensorTypePred,
    CPred<"::llvm::all_of(::llvm::cast<::mlir::RankedTensorType>($_self).getShape(), [](auto v) { return v != 0; })">]>;

def AllDimensionsAreSizeOne : And<[
    IsRankedTensorTypePred,
    CPred<"::llvm::all_of(::llvm::cast<::mlir::RankedTensorType>($_self).getShape(), [](auto v) { return v == 1; })">]>;

def AtLeastRankOne : And<[
  IsRankedTensorTypePred,
  CPred<"::llvm::cast<::mlir::RankedTensorType>($_self).getRank() >= 1">]>;

class LLNIRTensorOf<
    list<Type> allowedTypes, string summary = "tosa-conformant tensor">
    : TensorOf<allowedTypes, [Or<[HasNo0Dimensions, IsUnrankedTensorTypePred]>], summary>;

class LLNIRRankedTensorOf<
    list<Type> allowedTypes, list<Pred> preds = [], string summary = "tosa-conformant ranked tensor">
    : RankedTensorOf<allowedTypes, !listconcat([HasNo0Dimensions], preds), summary>;

class LLNIRUnrankedTensorOf<list<Type> allowedTypes, list<Pred> preds = [], string summary = "tosa-conformant unranked tensor">
    : UnrankedTensorOf<allowedTypes, preds, summary>;

class LLNIRTensorRankOf<list<Type> allowedTypes, list<int> ranks>
    : LLNIRRankedTensorOf<allowedTypes,
      [HasAnyRankOfPred<ranks>],
      !interleave(!foreach(rank, ranks, rank # "D"), "/") # " tensor">;

class LLNIRScalarTensorOf<list<Type> allowedTypes, list<int> ranks>
    : LLNIRRankedTensorOf<allowedTypes,
      [HasAnyRankOfPred<ranks>, AllDimensionsAreSizeOne],
      "tosa-conformant scalar tensor">;

//===----------------------------------------------------------------------===//
// Tensor types
//===----------------------------------------------------------------------===//

def LLNIR_I1Tensor : LLNIRTensorOf<[I1]>;
def LLNIR_Int32Tensor : LLNIRTensorOf<[LLNIR_Int32]>;
def LLNIR_Int32Or64Tensor : LLNIRTensorOf<[LLNIR_Int32Or64]>;

def LLNIR_FloatTensor : LLNIRTensorOf<[AnyFloat]>;

// Either ranked or unranked tensor of LLNIR supported element types.
def LLNIR_Tensor : LLNIRTensorOf<[LLNIR_AnyNumber]>;

// Must be ranked but no further constraints
def LLNIR_RankedTensor : LLNIRRankedTensorOf<[LLNIR_AnyNumber]>;

// Any tensor element type allowed in LLNIR ops.
def LLNIR_ElementType : Type<Or<[LLNIR_Int.predicate, LLNIR_QuantizedInt.predicate,
                                AnyFloat.predicate]>, "tosa.dtype">;

class LLNIR_TensorOfOrNone<list<Type> allowedTypes, string description = ""> :
  AnyTypeOf<[LLNIRTensorOf<allowedTypes>, NoneType], description>;

//===----------------------------------------------------------------------===//
// Tensor types with constrained ranks.
//===----------------------------------------------------------------------===//

def LLNIR_Rank0Tensor : LLNIRTensorRankOf<[LLNIR_AnyNumber], [0]>;

def LLNIR_ScalarTensor : AnyTypeOf<[LLNIRUnrankedTensorOf<[LLNIR_Int, AnyFloat]>, LLNIRScalarTensorOf<[LLNIR_AnyNumber], [1]>]>;
def LLNIR_ScalarInt8Tensor : AnyTypeOf<[LLNIRUnrankedTensorOf<[LLNIR_Int8]>, LLNIRScalarTensorOf<[LLNIR_Int8], [1]>]>;
def LLNIR_ScalarIntOrFloatTensor : AnyTypeOf<[LLNIRUnrankedTensorOf<[LLNIR_Int, AnyFloat]>, LLNIRScalarTensorOf<[LLNIR_Int, AnyFloat], [1]>]>;

// We include unranked tensors as a supported type for all possible tosa
// Tensors as unranked does not guarantee invalid. If unranked tensors exist
// they should be shape propagate used LLNIR's shape inference pass and verified
// to not include any remaining unranked tensors.
def LLNIR_UnrankedTensor : LLNIRUnrankedTensorOf<[LLNIR_AnyNumber]>;

def LLNIR_Tensor1D : AnyTypeOf<[LLNIR_UnrankedTensor, LLNIRTensorRankOf<[LLNIR_AnyNumber], [1]>], "1-d tosa-conformant tensor", "::mlir::TensorType">;
def LLNIR_Tensor2D : AnyTypeOf<[LLNIR_UnrankedTensor, LLNIRTensorRankOf<[LLNIR_AnyNumber], [2]>], "2-d tosa-conformant tensor", "::mlir::TensorType">;
def LLNIR_Tensor3D : AnyTypeOf<[LLNIR_UnrankedTensor, LLNIRTensorRankOf<[LLNIR_AnyNumber], [3]>], "3-d tosa-conformant tensor", "::mlir::TensorType">;
def LLNIR_Tensor4D : AnyTypeOf<[LLNIR_UnrankedTensor, LLNIRTensorRankOf<[LLNIR_AnyNumber], [4]>], "4-d tosa-conformant tensor", "::mlir::TensorType">;
def LLNIR_Tensor5D : AnyTypeOf<[LLNIR_UnrankedTensor, LLNIRTensorRankOf<[LLNIR_AnyNumber], [5]>], "5-d tosa-conformant tensor", "::mlir::TensorType">;

// 1D tensor of specific types
def LLNIR_1DInt8Tensor : 1DTensorOf<[LLNIR_Int8]>;
def LLNIR_1DInt16Or32Tensor : 1DTensorOf<[LLNIR_Int16Or32]>;

// Ranked tensors up to given rank.
def LLNIR_Tensor1Dto4D : AnyTypeOf<[
  LLNIR_UnrankedTensor, LLNIRTensorRankOf<[LLNIR_AnyNumber], [1,2,3,4]>]>;
def LLNIR_Tensor1Dto6D : AnyTypeOf<[
  LLNIR_UnrankedTensor, LLNIRTensorRankOf<[LLNIR_AnyNumber], [1,2,3,4,5,6]>]>;

def LLNIR_TensorUpto4D : AnyTypeOf<[
  LLNIR_UnrankedTensor, LLNIRTensorRankOf<[LLNIR_AnyNumber], [0,1,2,3,4]>]>;

def LLNIR_Int32TensorUpto4D : AnyTypeOf<[
  LLNIR_UnrankedTensor, LLNIRTensorRankOf<[LLNIR_Int32], [0,1,2,3,4]>]>;
def LLNIR_Int32Tensor2D : AnyTypeOf<[
  LLNIR_UnrankedTensor, LLNIRTensorRankOf<[LLNIR_Int32], [2]>]>;

def LLNIR_TensorAtLeast1D : AnyTypeOf<[
  LLNIR_UnrankedTensor, LLNIRRankedTensorOf<[LLNIR_AnyNumber], [AtLeastRankOne]>], "tosa-conformant tensor of at least rank 1", "::mlir::TensorType">;

//===----------------------------------------------------------------------===//
// Generic scalar, vector, or tensor of a particular type.
//===----------------------------------------------------------------------===//

class LLNIR_TypeLike<list<Type> types, string description = ""> : TypeConstraint<Or<[
     AnyTypeOf<types>.predicate,
     VectorOfNonZeroRankOf<types>.predicate,
     LLNIRTensorOf<types>.predicate]>,
     description>;

def LLNIR_IntLike : LLNIR_TypeLike<[LLNIR_Int], "signless-integer-like">;
def LLNIR_Int8Like : LLNIR_TypeLike<[LLNIR_Int8], "signless-integer-8-bit-like">;

//===----------------------------------------------------------------------===//
// Attribute predicates and classes.
//===----------------------------------------------------------------------===//

def LLNIR_Fp32ArrayAttr2 : ConfinedAttr<DenseF32ArrayAttr, [DenseArrayCount<2>]>;
def LLNIR_Fp32ArrayAttr3 : ConfinedAttr<DenseF32ArrayAttr, [DenseArrayCount<3>]>;
def LLNIR_Fp32ArrayAttr4 : ConfinedAttr<DenseF32ArrayAttr, [DenseArrayCount<4>]>;
def LLNIR_Fp32ArrayAttr5 : ConfinedAttr<DenseF32ArrayAttr, [DenseArrayCount<5>]>;
def LLNIR_Fp32ArrayAttr6 : ConfinedAttr<DenseF32ArrayAttr, [DenseArrayCount<6>]>;

def LLNIR_IntArrayAttr2 : ConfinedAttr<DenseI64ArrayAttr, [DenseArrayCount<2>]>;
def LLNIR_IntArrayAttr3 : ConfinedAttr<DenseI64ArrayAttr, [DenseArrayCount<3>]>;
def LLNIR_IntArrayAttr4 : ConfinedAttr<DenseI64ArrayAttr, [DenseArrayCount<4>]>;
def LLNIR_IntArrayAttr5 : ConfinedAttr<DenseI64ArrayAttr, [DenseArrayCount<5>]>;
def LLNIR_IntArrayAttr6 : ConfinedAttr<DenseI64ArrayAttr, [DenseArrayCount<6>]>;

def LLNIR_IntArrayAttrUpto2 : ConfinedAttr<DenseI64ArrayAttr, [DenseArrayMaxCt<2>]>;
def LLNIR_IntArrayAttrUpto4 : ConfinedAttr<DenseI64ArrayAttr, [DenseArrayMaxCt<4>]>;
def LLNIR_IntArrayAttrUpto5 : ConfinedAttr<DenseI64ArrayAttr, [DenseArrayMaxCt<5>]>;

def LLNIR_FloatAttr : Attr<CPred<"::llvm::isa<::mlir::FloatAttr>($_self)">,
                          "arbitrary float attribute"> {
  let storageType = [{ ::mlir::FloatAttr }];
  let returnType = [{ ::mlir::APFloat }];
}

def LLNIR_IntegerAttr : Attr<CPred<"::llvm::isa<::mlir::IntegerAttr>($_self)">,
                          "arbitrary integer attribute"> {
  let storageType = [{ ::mlir::IntegerAttr }];
  let returnType = [{ ::llvm::APInt }];
}

def LLNIR_IntOrFloatAttr : AnyAttrOf<[LLNIR_IntegerAttr, LLNIR_FloatAttr]>;


def LLNIR_TensorTypeAttr : TypeAttrBase<"TensorType", "Tensor type attribute">;

// Tensor to buffer types.
def LLNIR_Buffer : MemRefOf<[LLNIR_AnyNumber]>;
def LLNIR_TupleBuffer : NestedTupleOf<[LLNIR_Buffer]>;
def LLNIR_BufOrTuple : AnyTypeOf<[LLNIR_Buffer, LLNIR_TupleBuffer]>;

//===----------------------------------------------------------------------===//
// LLNIR Type Definitions.
//===----------------------------------------------------------------------===//

// The base class for LLNIR dialect types.
class LLNIR_Type<string name, string typeMnemonic, list<Trait> traits = []>
    : TypeDef<LLNIR_Dialect, name, traits> {
  let mnemonic = typeMnemonic;
}

//===----------------------------------------------------------------------===//
// ShapeType
//===----------------------------------------------------------------------===//
def LLNIR_Shape : LLNIR_Type<"shape", "shape"> {
  let summary = "Shape with static rank and Index element type";
  let description = [{
    Syntax:

    ``` shape - type :: = `shape` `<` rank `>`
    ``` Values with shape type represents a shape with a fixed rank and a list
                               of dimensions
                                   .Rank must be zero or a positive integer
                                   .Each dimension is represented by the builtin
                                       Index type.

    Examples:

    ```mlir
     // Shape with rank of four, for example, [1, 1, 8, 16]:
     !tosa
         .shape<4>

     // Shape with rank of one, for example, [16]:
     !tosa
         .shape<1>

     // Shape with rank zero, for example, [] (i.e., shape of scalar values):
     !tosa.shape<0>
    ```
  }];
  let parameters = (ins "int" : $rank);
  let builders = [TypeBuilder<(ins "int" : $rank)>];
  let assemblyFormat = "`<` $rank `>`";

  let genVerifyDecl = 1;
}

def IsLLNIRShapeType : CPred<"mlir::tosa::isa_tosa_shape_type($_self)">;

// Whether a LLNIR Shape type has a rank equal to the specified rank.
class IsLLNIRShapeOfRankPred<int rank> : And<[
  IsLLNIRShapeType,
  CPred<[{::llvm::cast<::mlir::tosa::shapeType>($_self).getRank() == }] # rank>
]>;

class LLNIRShapeOfRank<int rank>
    : Type<IsLLNIRShapeOfRankPred<rank>, "LLNIR shape type of rank " #rank>;

def Rank1LLNIRShape : LLNIRShapeOfRank<1>;
def Rank2LLNIRShape : LLNIRShapeOfRank<2>;
def Rank4LLNIRShape : LLNIRShapeOfRank<4>;

//===----------------------------------------------------------------------===//
// CustomType
//===----------------------------------------------------------------------===//

def LLNIR_CustomType : LLNIR_Type<"Custom", "custom"> {
    let summary = "LLNIR custom type";
    let description = "Custom type in llnir dialect";
    let parameters = (ins StringRefParameter<"the custom value">:$value);
    let assemblyFormat = "`<` $value `>`";
}


#endif // MLIR_DIALECT_LLNIR_IR_LLNIRTYPES_TD
