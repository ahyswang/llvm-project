//===----------------------------------------------------------------------===//
//
// Copyright (C) 2022 Sophgo Technologies Inc.  All rights reserved.
//
// LLN-MLIR is licensed under the 2-Clause BSD License except for the
// third-party components.
//
//===----------------------------------------------------------------------===//

// =============================================================================
//
// Defines LL Dialect operations.
//
//===----------------------------------------------------------------------===//

#ifndef LLN_MLIR_LLIR_OPS
#define LLN_MLIR_LLIR_OPS

include "mlir/IR/AttrTypeBase.td"
include "mlir/IR/EnumAttr.td"
include "mlir/IR/OpBase.td"
include "LLN/Dialect/LLIR/IR/LLIROpsInterfaces.td"

// =============================================================================
//
// Defines LLIR Dialect.
//
//===----------------------------------------------------------------------===//

def LLIR_Dialect : Dialect {
  let name = "llir";
  let summary = "A topdialect for the LLN_MLIR specification";
  let cppNamespace = "::lln_mlir::llir";
}

//===----------------------------------------------------------------------===//
// LLIR Attributes.
//===----------------------------------------------------------------------===//

class LLIR_Attr<string attrName, string attrMnemonic, list<Trait> traits = []>
    : AttrDef<LLIR_Dialect, attrName, traits> {
  let mnemonic = attrMnemonic;
}

// A string attribute whose value are one of the values in `cases`.
class AnyStrAttrOf<list<string> cases> : StringBasedAttr<
  CPred<!foldl(
      "$_self.cast<StringAttr>().getValue() == \"" # !head(cases) # "\"",
      !foreach(case, !tail(cases),
               "$_self.cast<StringAttr>().getValue() == \"" # case # "\""),
      prev, cur, prev # " || " # cur)>,
  "string attribute whose value is " #
    !foldl(/*init*/!head(cases), /*list*/!tail(cases),
           prev, cur, prev # ", or " # cur)>;

def ReduceModeAttr: AnyStrAttrOf<["ReduceMin","ReduceMax","ReduceMean","ReduceL2","ReduceL1","ReduceSum","ReduceProd"]>;
def RoundModeAttr: AnyStrAttrOf<["HalfAwayFromZero", "HalfUp", "HalfDown", "HalfToEven", "HalfToOdd", "HalfTowardsZero", "TowardsZero", "Up", "Down"]>;

//===----------------------------------------------------------------------===//
// LLIR Types.
//===----------------------------------------------------------------------===//

def AnyTensorOrNone: AnyTypeOf<[AnyTensor, NoneType]>;

//===----------------------------------------------------------------------===//
// LLIR Op Definition.
//===----------------------------------------------------------------------===//

// === BaseOp =====
class LLIR_BaseOp<string mnemonic, list<Trait> traits = []> :
    Op<LLIR_Dialect, mnemonic, traits> ;

def LLIR_NoneOp : LLIR_BaseOp<"None"> {
  let summary = "none operator";

  let description = [{
    A none Op to return a NoneType.
  }];
  let results = (outs NoneType);
}

// === Function Op =====
class LLIR_Op<string mnemonic, list<Trait> traits = []> :
    LLIR_BaseOp<mnemonic, !listconcat(traits,
       [DeclareOpInterfaceMethods<ShapeInterface>])>;

def LLIR_AddOp: LLIR_Op<"Add", []> {
  let summary = "add operator";

  let description = [{
    1.Op Introduction
    Elementwise addition of input1 and input2. Axis of size 1 will be broadcast,
    as necessary.

    2.Math formula
    ```math
        output = input1 + input2;
    ```
    Axis of size 1 will be broadcast if necessary.

    3.activation and weight
    
    4.attribute
  }];

  let arguments = (ins
    Variadic<AnyTensor>:$inputs
  );

  let results = (outs AnyTensor:$output);
  let hasCanonicalizer = 1;
}

#endif //LLN_MLIR_LLIR_OPS