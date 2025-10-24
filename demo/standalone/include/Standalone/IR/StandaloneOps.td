//===- StandaloneOps.td - Standalone dialect ops -----------*- tablegen -*-===//
//
// This file is licensed under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef MLIR_DIALECT_STANDALONE_IR_STANDALONEOPS_TD
#define MLIR_DIALECT_STANDALONE_IR_STANDALONEOPS_TD

include "mlir/IR/OpBase.td"

include "mlir/Interfaces/InferTypeOpInterface.td"
include "mlir/Interfaces/SideEffectInterfaces.td"
include "mlir/Interfaces/LoopLikeInterface.td"
include "mlir/Bytecode/BytecodeOpInterface.td"

include "Standalone/IR/StandaloneTypes.td"
include "Standalone/IR/StandaloneBase.td"

//===----------------------------------------------------------------------===//
// Operator Class: Bitwise Operators.
//===----------------------------------------------------------------------===//



//===----------------------------------------------------------------------===//
// Operator Class: Tensor Operators.
//===----------------------------------------------------------------------===//


//===----------------------------------------------------------------------===//
// Operator Class: Activation Functions.
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
// Operator: clamp
//===----------------------------------------------------------------------===//
def Standalone_ClampOp : Standalone_ElementwiseUnaryOp<"clamp"> {
  let summary = "Computes clamp(features, min, max).";

  let description = [{
    Clamp to an arbitrary minimum and maximum value.
    Maximum and minimum values are specified as values in the range of the
    input type.
    No zero point subtraction is done to the values, thus to clamp to the zero
    point value, the zero point itself should be supplied as the minimum value.
  }];

  let arguments = (ins
    Standalone_Tensor:$input,
    Standalone_IntOrFloatAttr:$min_val,
    Standalone_IntOrFloatAttr:$max_val,
    DefaultValuedAttr<Standalone_NanPropagationModeAttr, "::mlir::standalone::NanPropagationMode::PROPAGATE">:$nan_mode
  );

  let results = (outs
    Standalone_Tensor:$output
  );

  //let hasCanonicalizer = 1;
  //let hasVerifier = 1;
  let hasCustomAssemblyFormat = 1;
}

//===----------------------------------------------------------------------===//
// Operator Class: Elementwise Binary Operators.
//===----------------------------------------------------------------------===//


//===----------------------------------------------------------------------===//
// Operator Class: Reduction Operators.
//===----------------------------------------------------------------------===//


//===----------------------------------------------------------------------===//
// Operator Class: Data Layout.
//===----------------------------------------------------------------------===//


//===----------------------------------------------------------------------===//
// Operator Class: Scatter/Gather Operators.
//===----------------------------------------------------------------------===//


//===----------------------------------------------------------------------===//
// Operator Class: Image Operators.
//===----------------------------------------------------------------------===//


//===----------------------------------------------------------------------===//
// Operator Class: Type Conversion.
//===----------------------------------------------------------------------===//


//===----------------------------------------------------------------------===//
// Operator Class: Data Nodes.
//===----------------------------------------------------------------------===//


//===----------------------------------------------------------------------===//
// Operator Class: Custom Operators.
//===----------------------------------------------------------------------===//


//===----------------------------------------------------------------------===//
// Operator Class: Control Flow Operators.
//===----------------------------------------------------------------------===//


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
    Standalone_Tensor:$input1,
    Standalone_Tensor:$input2
  );

  let results = (outs 
    Standalone_Tensor:$output
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
    Standalone_Tensor:$input1,
    Standalone_Tensor:$input2
    // Apply right shift on i32_t input data only
    //Standalone_ScalarInt8Tensor:$shift
  );

  let results = (outs
    Standalone_Tensor:$output
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

//===----------------------------------------------------------------------===//
// Operator: conv2d
//===----------------------------------------------------------------------===//
def Standalone_Conv2DOp : Standalone_ConvOp<"conv2d"> {
  let summary = "2D Convolution operator.";

  let description = [{
    Performs a 2D convolution over the given tensor input, using the weight
    tensor. Implementations may choose to skip calculation of multiplies in
    the padding area.
  }];

  let arguments = (ins
    Standalone_Tensor4D:$input,
    Standalone_Tensor4D:$weight,
    Standalone_Tensor1D:$bias,
    Standalone_ScalarIntOrFloatTensor:$input_zp,
    Standalone_ScalarIntOrFloatTensor:$weight_zp,

    Standalone_IntArrayAttr4:$pad,
    Standalone_IntArrayAttr2:$stride,
    Standalone_IntArrayAttr2:$dilation,
    //TypeAttrOf<Standalone_AccType>:$acc_type,
    DefaultValuedOptionalAttr<BoolAttr, "false">:$local_bound
  );

  let results = (outs
    Standalone_Tensor4D:$output
  );

  //let builders = [Standalone_ConvOpQuantInfoBuilder];

  //let hasCanonicalizer = 1;
  //let hasVerifier = 1;
}


#endif // MLIR_DIALECT_STANDALONE_IR_STANDALONEOPS_TD
