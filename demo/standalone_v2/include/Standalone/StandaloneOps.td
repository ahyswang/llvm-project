//===- StandaloneOps.td - Standalone dialect ops -----------*- tablegen -*-===//
//
// This file is licensed under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef STANDALONE_OPS
#define STANDALONE_OPS

include "mlir/IR/OpBase.td"

include "mlir/Interfaces/InferTypeOpInterface.td"
include "mlir/Interfaces/SideEffectInterfaces.td"
include "mlir/Interfaces/LoopLikeInterface.td"
include "mlir/Bytecode/BytecodeOpInterface.td"

include "Standalone/StandaloneTypes.td"
include "Standalone/StandaloneDialect.td"


def Standalone_FooOp : Standalone_Op<"foo", [Pure,
                                             SameOperandsAndResultType]> {
    let summary = "Illustrates how to define an operation.";
    let description = [{
        The `standalone.foo` operation illustrates how to define a new
        operation in a dialect. It uses an operation trait to declare that it
        has no side effects.

        This operation takes an integer argument and returns an integer.

        Example:

        ```mlir
        %0 = arith.constant 2 : i32
        // Apply the foo operation to %0
        %1 = standalone.foo %0 : i32
        ```
    }];

    let arguments = (ins I32:$input);
    let results = (outs I32:$res);

    let assemblyFormat = [{
        $input attr-dict `:` type($input)
    }];
}

//===----------------------------------------------------------------------===//
// Operator Class: Elementwise Binary Operators.
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
// Operator: add
//===----------------------------------------------------------------------===//

def Standalone_AddOp: Standalone_ElementwiseOp<"add", [ 
    Commutative,
    SameOperandsAndResultElementType
    ]> {
  let summary = "add operator";

  let description = [{
    Elementwise addition of input1 and input2. Axis of size 1 will be broadcast,
    as necessary. Rank of input tensors must match.

    Example:

    ```mlir
    // Elementwise addition.
    %out = standalone.add %input1, %input2 : tensor<12x6xf32>, tensor<12x6xf32> -> tensor<12x6xf32>

    // Elementwise addition with broadcasting.
    %out = standalone.add %input1, %input2 : tensor<12x6xsi32>, tensor<1x1xsi32> -> tensor<12x6xsi32>
    ```
  }];

  let arguments = (ins
    //Variadic<AnyTensor>:$inputs
    AnyTensor:$input1,
    AnyTensor:$input2
  );

  let results = (outs 
    AnyTensor:$output
  );
  //let hasCanonicalizer = 1;
  let hasFolder = 1;
  //let hasCustomAssemblyFormat = 1;
  //let assemblyFormat = "operands attr-dict `:` functional-type(operands, results)";
}
 
//===----------------------------------------------------------------------===//
// Operator: mul
//===----------------------------------------------------------------------===//
def Standalone_MulOp : Standalone_Op<"mul", [
    DeclareOpInterfaceMethods<InferShapedTypeOpInterface,
                              ["inferReturnTypeComponents"]>,
    Commutative,
    Pure]> {
  let summary = "Multiplication operator.";

  let description = [{
    Elementwise multiplication (Hadamard product) of input1 and input2.
    Axis of size 1 will be broadcast, as necessary. Rank of input tensors must
    match.
  }];

  let arguments = (ins
    AnyTensor:$input1,
    AnyTensor:$input2
    // Apply right shift on i32_t input data only
    //Tosa_ScalarInt8Tensor:$shift
  );

  let results = (outs
    AnyTensor:$output
  );

  let hasFolder = 1;
  let hasVerifier = 1;

  //let assemblyFormat =
  //    "operands attr-dict `:` functional-type(operands, results)";
}

//===----------------------------------------------------------------------===//
// Operator Class: Data Nodes.
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
// Operator: const
//===----------------------------------------------------------------------===//
 
def Standalone_ConstOp : Standalone_Op<"const", [ConstantLike, Pure,
                                      AllShapesMatch<["values", "output"]>,
                                      FirstAttrDerivedResultType]> {
  let summary = "Constant operator.";

  let description = [{
    A node containing constant data for use as the input to an operation. May
    hold data in any of the supported data formats.

    Example:

    ```mlir
    // Generic form
    %out = "standalone.const"() {values = dense<0> : tensor<2x3xi32>} : () -> tensor<2x3xi32>
    ```
  }];

  let arguments = (ins
    ElementsAttr:$values
  );

  let results = (outs
    AnyTensor:$output
  );

  let hasFolder = 1;
  let hasVerifier = 1;
}

#endif // STANDALONE_OPS
