//===- StandaloneOps.td - Standalone dialect ops -----------*- tablegen -*-===//
//
// This file is licensed under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef STANDALONE_OPS
#define STANDALONE_OPS

include "Standalone/StandaloneTypes.td"
include "mlir/Interfaces/InferTypeOpInterface.td"
include "mlir/Interfaces/SideEffectInterfaces.td"

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

def Standalone_AddOp : Standalone_Op<"add", [
    Commutative,
    SameOperandsAndResultType]> {
    let summary = "Elementwise addition operator.";

    let description = [{
        Elementwise addition of input1 and input2. Axis of size 1 will be broadcast,
        as necessary. Rank of input tensors must match.

        Example:

        ```mlir
        // Elementwise addition.
        %out = standalone.add %input1, %input2 : (tensor<12x6xf32>, tensor<12x6xf32>) -> tensor<12x6xf32>

        // Elementwise addition with broadcasting.
        %out = standalone.add %input1, %input2 : (tensor<12x6xsi32>, tensor<1x1xsi32>) -> tensor<12x6xsi32>
        ```
    }];

    let arguments = (ins 
        Standalone_Tensor:$input1,
        Standalone_Tensor:$input2
    );

    let results = (outs
        Standalone_Tensor:$output
    );

    let assemblyFormat = "operands attr-dict `:` functional-type(operands, results)";
}

#endif // STANDALONE_OPS
