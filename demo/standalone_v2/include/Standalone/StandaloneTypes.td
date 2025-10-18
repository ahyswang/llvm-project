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


//===----------------------------------------------------------------------===//
// ShapeType
//===----------------------------------------------------------------------===//
def Standaone_Shape : Standalone_Type<"shape", "shape"> {
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

#endif // STANDALONE_TYPES
