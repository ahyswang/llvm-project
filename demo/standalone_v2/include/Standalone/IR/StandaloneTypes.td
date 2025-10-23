//===-- StandaloneTypesBase.td - STANDALONE type definitions -----------*- tablegen -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file defines the type definitions for the STANDALONE dialect.
//
//===----------------------------------------------------------------------===//

#ifndef STANDALONE_TYPES_BASE
#define STANDALONE_TYPES_BASE

include "mlir/IR/AttrTypeBase.td"
include "mlir/IR/OpBase.td"

include "Standalone/IR/StandaloneDialect.td"

//===----------------------------------------------------------------------===//
// Standalone Type Definitions.
//===----------------------------------------------------------------------===//

// The base class of a quantized type.
// Param tuple is: [bitwidth, zeropt, smantissa, sexp, low_end, high_end].
// Where low and high ends are 0,255 when unsigned, -128,127 when signed, for
// the 8-bit case.
class Standalone_QuantizedType<string n, list<int> params, bit signed>
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

def Standalone_Int4 : I<4>;
def Standalone_Int8 : I<8>;
def Standalone_Int16 : I<16>;
def Standalone_Int32 : I<32>;
def Standalone_Int64 : I<64>;

// The STANDALONE dialect allows more types than the STANDALONE standard to allow for
// experimentation. For historical reasons, signless is used in the place of
// signed.
// The StandaloneValidation pass can be used to check for standard conformance.
def Standalone_Int : AnyTypeOf<[AnyUnsignedInteger,
                          AnySignlessInteger]>;

def Standalone_Int32Or64 : AnyTypeOf<[Standalone_Int32,
                                Standalone_Int64]>;

def Standalone_Int16Or32 : AnyTypeOf<[Standalone_Int16,
                                Standalone_Int32]>;

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
def Standalone_QuantizedInt : AnyTypeOf<[Standalone_QuantizedType<"uint8", [8], 0>,
                                   Standalone_QuantizedType<"int4", [4, 0], 1>,
                                   Standalone_QuantizedType<"int8", [8, 0], 1>,
                                   Standalone_QuantizedType<"int16", [16, 0], 1>,
                                   Standalone_QuantizedType<"int32", [32, 0], 1>]>;

//===----------------------------------------------------------------------===//
// Multi-category types.
//===----------------------------------------------------------------------===//
def Standalone_AnyNumber : AnyTypeOf<[Standalone_Int, Standalone_QuantizedInt, AnyFloat],
                                "number">;

//===----------------------------------------------------------------------===//
// STANDALONE Tensor Conformance
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

class StandaloneTensorOf<
    list<Type> allowedTypes, string summary = "tosa-conformant tensor">
    : TensorOf<allowedTypes, [Or<[HasNo0Dimensions, IsUnrankedTensorTypePred]>], summary>;

class StandaloneRankedTensorOf<
    list<Type> allowedTypes, list<Pred> preds = [], string summary = "tosa-conformant ranked tensor">
    : RankedTensorOf<allowedTypes, !listconcat([HasNo0Dimensions], preds), summary>;

class StandaloneUnrankedTensorOf<list<Type> allowedTypes, list<Pred> preds = [], string summary = "tosa-conformant unranked tensor">
    : UnrankedTensorOf<allowedTypes, preds, summary>;

class StandaloneTensorRankOf<list<Type> allowedTypes, list<int> ranks>
    : StandaloneRankedTensorOf<allowedTypes,
      [HasAnyRankOfPred<ranks>],
      !interleave(!foreach(rank, ranks, rank # "D"), "/") # " tensor">;

class StandaloneScalarTensorOf<list<Type> allowedTypes, list<int> ranks>
    : StandaloneRankedTensorOf<allowedTypes,
      [HasAnyRankOfPred<ranks>, AllDimensionsAreSizeOne],
      "tosa-conformant scalar tensor">;

//===----------------------------------------------------------------------===//
// Tensor types
//===----------------------------------------------------------------------===//

def Standalone_I1Tensor : StandaloneTensorOf<[I1]>;
def Standalone_Int32Tensor : StandaloneTensorOf<[Standalone_Int32]>;
def Standalone_Int32Or64Tensor : StandaloneTensorOf<[Standalone_Int32Or64]>;

def Standalone_FloatTensor : StandaloneTensorOf<[AnyFloat]>;

// Either ranked or unranked tensor of STANDALONE supported element types.
def Standalone_Tensor : StandaloneTensorOf<[Standalone_AnyNumber]>;

// Must be ranked but no further constraints
def Standalone_RankedTensor : StandaloneRankedTensorOf<[Standalone_AnyNumber]>;

// Any tensor element type allowed in Standalone ops.
def Standalone_ElementType : Type<Or<[Standalone_Int.predicate, Standalone_QuantizedInt.predicate,
                                AnyFloat.predicate]>, "tosa.dtype">;

class Standalone_TensorOfOrNone<list<Type> allowedTypes, string description = ""> :
  AnyTypeOf<[StandaloneTensorOf<allowedTypes>, NoneType], description>;

//===----------------------------------------------------------------------===//
// Tensor types with constrained ranks.
//===----------------------------------------------------------------------===//

def Standalone_Rank0Tensor : StandaloneTensorRankOf<[Standalone_AnyNumber], [0]>;

def Standalone_ScalarTensor : AnyTypeOf<[StandaloneUnrankedTensorOf<[Standalone_Int, AnyFloat]>, StandaloneScalarTensorOf<[Standalone_AnyNumber], [1]>]>;
def Standalone_ScalarInt8Tensor : AnyTypeOf<[StandaloneUnrankedTensorOf<[Standalone_Int8]>, StandaloneScalarTensorOf<[Standalone_Int8], [1]>]>;
def Standalone_ScalarIntOrFloatTensor : AnyTypeOf<[StandaloneUnrankedTensorOf<[Standalone_Int, AnyFloat]>, StandaloneScalarTensorOf<[Standalone_Int, AnyFloat], [1]>]>;

// We include unranked tensors as a supported type for all possible tosa
// Tensors as unranked does not guarantee invalid. If unranked tensors exist
// they should be shape propagate used Standalone's shape inference pass and verified
// to not include any remaining unranked tensors.
def Standalone_UnrankedTensor : StandaloneUnrankedTensorOf<[Standalone_AnyNumber]>;

def Standalone_Tensor1D : AnyTypeOf<[Standalone_UnrankedTensor, StandaloneTensorRankOf<[Standalone_AnyNumber], [1]>], "1-d tosa-conformant tensor", "::mlir::TensorType">;
def Standalone_Tensor2D : AnyTypeOf<[Standalone_UnrankedTensor, StandaloneTensorRankOf<[Standalone_AnyNumber], [2]>], "2-d tosa-conformant tensor", "::mlir::TensorType">;
def Standalone_Tensor3D : AnyTypeOf<[Standalone_UnrankedTensor, StandaloneTensorRankOf<[Standalone_AnyNumber], [3]>], "3-d tosa-conformant tensor", "::mlir::TensorType">;
def Standalone_Tensor4D : AnyTypeOf<[Standalone_UnrankedTensor, StandaloneTensorRankOf<[Standalone_AnyNumber], [4]>], "4-d tosa-conformant tensor", "::mlir::TensorType">;
def Standalone_Tensor5D : AnyTypeOf<[Standalone_UnrankedTensor, StandaloneTensorRankOf<[Standalone_AnyNumber], [5]>], "5-d tosa-conformant tensor", "::mlir::TensorType">;

// 1D tensor of specific types
def Standalone_1DInt8Tensor : 1DTensorOf<[Standalone_Int8]>;
def Standalone_1DInt16Or32Tensor : 1DTensorOf<[Standalone_Int16Or32]>;

// Ranked tensors up to given rank.
def Standalone_Tensor1Dto4D : AnyTypeOf<[
  Standalone_UnrankedTensor, StandaloneTensorRankOf<[Standalone_AnyNumber], [1,2,3,4]>]>;
def Standalone_Tensor1Dto6D : AnyTypeOf<[
  Standalone_UnrankedTensor, StandaloneTensorRankOf<[Standalone_AnyNumber], [1,2,3,4,5,6]>]>;

def Standalone_TensorUpto4D : AnyTypeOf<[
  Standalone_UnrankedTensor, StandaloneTensorRankOf<[Standalone_AnyNumber], [0,1,2,3,4]>]>;

def Standalone_Int32TensorUpto4D : AnyTypeOf<[
  Standalone_UnrankedTensor, StandaloneTensorRankOf<[Standalone_Int32], [0,1,2,3,4]>]>;
def Standalone_Int32Tensor2D : AnyTypeOf<[
  Standalone_UnrankedTensor, StandaloneTensorRankOf<[Standalone_Int32], [2]>]>;

def Standalone_TensorAtLeast1D : AnyTypeOf<[
  Standalone_UnrankedTensor, StandaloneRankedTensorOf<[Standalone_AnyNumber], [AtLeastRankOne]>], "tosa-conformant tensor of at least rank 1", "::mlir::TensorType">;

//===----------------------------------------------------------------------===//
// Generic scalar, vector, or tensor of a particular type.
//===----------------------------------------------------------------------===//

class Standalone_TypeLike<list<Type> types, string description = ""> : TypeConstraint<Or<[
     AnyTypeOf<types>.predicate,
     VectorOfNonZeroRankOf<types>.predicate,
     StandaloneTensorOf<types>.predicate]>,
     description>;

def Standalone_IntLike : Standalone_TypeLike<[Standalone_Int], "signless-integer-like">;
def Standalone_Int8Like : Standalone_TypeLike<[Standalone_Int8], "signless-integer-8-bit-like">;

//===----------------------------------------------------------------------===//
// Attribute predicates and classes.
//===----------------------------------------------------------------------===//

def Standalone_Fp32ArrayAttr2 : ConfinedAttr<DenseF32ArrayAttr, [DenseArrayCount<2>]>;
def Standalone_Fp32ArrayAttr3 : ConfinedAttr<DenseF32ArrayAttr, [DenseArrayCount<3>]>;
def Standalone_Fp32ArrayAttr4 : ConfinedAttr<DenseF32ArrayAttr, [DenseArrayCount<4>]>;
def Standalone_Fp32ArrayAttr5 : ConfinedAttr<DenseF32ArrayAttr, [DenseArrayCount<5>]>;
def Standalone_Fp32ArrayAttr6 : ConfinedAttr<DenseF32ArrayAttr, [DenseArrayCount<6>]>;

def Standalone_IntArrayAttr2 : ConfinedAttr<DenseI64ArrayAttr, [DenseArrayCount<2>]>;
def Standalone_IntArrayAttr3 : ConfinedAttr<DenseI64ArrayAttr, [DenseArrayCount<3>]>;
def Standalone_IntArrayAttr4 : ConfinedAttr<DenseI64ArrayAttr, [DenseArrayCount<4>]>;
def Standalone_IntArrayAttr5 : ConfinedAttr<DenseI64ArrayAttr, [DenseArrayCount<5>]>;
def Standalone_IntArrayAttr6 : ConfinedAttr<DenseI64ArrayAttr, [DenseArrayCount<6>]>;

def Standalone_IntArrayAttrUpto2 : ConfinedAttr<DenseI64ArrayAttr, [DenseArrayMaxCt<2>]>;
def Standalone_IntArrayAttrUpto4 : ConfinedAttr<DenseI64ArrayAttr, [DenseArrayMaxCt<4>]>;
def Standalone_IntArrayAttrUpto5 : ConfinedAttr<DenseI64ArrayAttr, [DenseArrayMaxCt<5>]>;

def Standalone_FloatAttr : Attr<CPred<"::llvm::isa<::mlir::FloatAttr>($_self)">,
                          "arbitrary float attribute"> {
  let storageType = [{ ::mlir::FloatAttr }];
  let returnType = [{ ::mlir::APFloat }];
}

def Standalone_IntegerAttr : Attr<CPred<"::llvm::isa<::mlir::IntegerAttr>($_self)">,
                          "arbitrary integer attribute"> {
  let storageType = [{ ::mlir::IntegerAttr }];
  let returnType = [{ ::llvm::APInt }];
}

def Standalone_IntOrFloatAttr : AnyAttrOf<[Standalone_IntegerAttr, Standalone_FloatAttr]>;


def Standalone_TensorTypeAttr : TypeAttrBase<"TensorType", "Tensor type attribute">;

// Tensor to buffer types.
def Standalone_Buffer : MemRefOf<[Standalone_AnyNumber]>;
def Standalone_TupleBuffer : NestedTupleOf<[Standalone_Buffer]>;
def Standalone_BufOrTuple : AnyTypeOf<[Standalone_Buffer, Standalone_TupleBuffer]>;

//===----------------------------------------------------------------------===//
// Standalone Type Definitions.
//===----------------------------------------------------------------------===//

// The base class for Standalone dialect types.
class Standalone_Type<string name, string typeMnemonic, list<Trait> traits = []>
    : TypeDef<Standalone_Dialect, name, traits> {
  let mnemonic = typeMnemonic;
}

//===----------------------------------------------------------------------===//
// ShapeType
//===----------------------------------------------------------------------===//
def Standalone_Shape : Standalone_Type<"shape", "shape"> {
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

def IsStandaloneShapeType : CPred<"mlir::tosa::isa_tosa_shape_type($_self)">;

// Whether a Standalone Shape type has a rank equal to the specified rank.
class IsStandaloneShapeOfRankPred<int rank> : And<[
  IsStandaloneShapeType,
  CPred<[{::llvm::cast<::mlir::tosa::shapeType>($_self).getRank() == }] # rank>
]>;

class StandaloneShapeOfRank<int rank>
    : Type<IsStandaloneShapeOfRankPred<rank>, "Standalone shape type of rank " #rank>;

def Rank1StandaloneShape : StandaloneShapeOfRank<1>;
def Rank2StandaloneShape : StandaloneShapeOfRank<2>;
def Rank4StandaloneShape : StandaloneShapeOfRank<4>;

//===----------------------------------------------------------------------===//
// CustomType
//===----------------------------------------------------------------------===//

def Standalone_CustomType : Standalone_Type<"Custom", "custom"> {
    let summary = "Standalone custom type";
    let description = "Custom type in standalone dialect";
    let parameters = (ins StringRefParameter<"the custom value">:$value);
    let assemblyFormat = "`<` $value `>`";
}


#endif // STANDALONE_TYPES_BASE
