//===- StandaloneTypes.td - Standalone dialect types -------*- tablegen -*-===//
//
// This file is licensed under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef STANDALONE_TYPES
#define STANDALONE_TYPES

include "mlir/IR/AttrTypeBase.td"
include "Standalone/StandaloneDialect.td"

//===----------------------------------------------------------------------===//
// Non-Quantized Signed Integer Types.
// Used to express accumulator results or compare results.
//===----------------------------------------------------------------------===//

def Standalone_Int : AnyTypeOf<[AnyUnsignedInteger,
                          AnySignlessInteger]>;


//===----------------------------------------------------------------------===//
// Multi-category types.
//===----------------------------------------------------------------------===//
def Standalone_AnyNumber : AnyTypeOf<[Standalone_Int, AnyFloat],
                                "number">;

//===----------------------------------------------------------------------===//
// Standalone Tensor Conformance
//===----------------------------------------------------------------------===//

def HasNo0Dimensions : And<[
    IsRankedTensorTypePred,
    CPred<"::llvm::all_of(::llvm::cast<::mlir::RankedTensorType>($_self).getShape(), [](auto v) { return v != 0; })">]>;


class StandaloneTensorOf<
    list<Type> allowedTypes, string summary = "standalone-conformant tensor">
    : TensorOf<allowedTypes, [Or<[HasNo0Dimensions, IsUnrankedTensorTypePred]>], summary>;


//===----------------------------------------------------------------------===//
// Tensor types
//===----------------------------------------------------------------------===//

// Either ranked or unranked tensor of Standalone supported element types.
def Standalone_Tensor : StandaloneTensorOf<[AnyFloat, AnySignlessInteger, AnyUnsignedInteger]>;

//===----------------------------------------------------------------------===//
// Standalone type definitions
//===----------------------------------------------------------------------===//

class Standalone_Type<string name, string typeMnemonic, list<Trait> traits = []>
    : TypeDef<Standalone_Dialect, name, traits> {
  let mnemonic = typeMnemonic;
}

def Standalone_CustomType : Standalone_Type<"Custom", "custom"> {
    let summary = "Standalone custom type";
    let description = "Custom type in standalone dialect";
    let parameters = (ins StringRefParameter<"the custom value">:$value);
    let assemblyFormat = "`<` $value `>`";
}

#endif // STANDALONE_TYPES
