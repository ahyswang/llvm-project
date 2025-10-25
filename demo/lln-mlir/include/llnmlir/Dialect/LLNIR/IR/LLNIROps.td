//===- LLNIROps.td - LLNIR dialect ops -----------*- tablegen -*-===//
//
// This file is licensed under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef MLIR_DIALECT_LLNIR_IR_LLNIROPS_TD
#define MLIR_DIALECT_LLNIR_IR_LLNIROPS_TD

include "mlir/IR/OpBase.td"

include "mlir/Interfaces/InferTypeOpInterface.td"
include "mlir/Interfaces/SideEffectInterfaces.td"
include "mlir/Interfaces/LoopLikeInterface.td"
include "mlir/Bytecode/BytecodeOpInterface.td"

include "llnmlir/Dialect/LLNIR/IR/LLNIRTypes.td"
include "llnmlir/Dialect/LLNIR/IR/LLNIRBase.td"

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
def LLNIR_ClampOp : LLNIR_ElementwiseUnaryOp<"clamp"> {
  let summary = "Computes clamp(features, min, max).";

  let description = [{
    Clamp to an arbitrary minimum and maximum value.
    Maximum and minimum values are specified as values in the range of the
    input type.
    No zero point subtraction is done to the values, thus to clamp to the zero
    point value, the zero point itself should be supplied as the minimum value.
  }];

  let arguments = (ins
    LLNIR_Tensor:$input,
    LLNIR_IntOrFloatAttr:$min_val,
    LLNIR_IntOrFloatAttr:$max_val,
    DefaultValuedAttr<LLNIR_NanPropagationModeAttr, "::mlir::llnir::NanPropagationMode::PROPAGATE">:$nan_mode
  );

  let results = (outs
    LLNIR_Tensor:$output
  );

  let hasCanonicalizer = 1;
  let hasVerifier = 1;
  let hasCustomAssemblyFormat = 1;
}

//===----------------------------------------------------------------------===//
// Operator Class: Elementwise Binary Operators.
//===----------------------------------------------------------------------===//


//===----------------------------------------------------------------------===//
// Operator: bitwise_and
//===----------------------------------------------------------------------===//
def LLNIR_BitwiseAndOp : LLNIR_ElementwiseOp<"bitwise_and", [
    Commutative,
    SameOperandsAndResultElementType]> {
  let summary = "Bitwise AND operator.";

  let description = [{
    Elementwise bitwise AND of input1 and input2. Axis of size 1
    will be broadcast as necessary. Rank of input tensors must match.

    precision supported:
    |Input    |Ouput    |
    |---------|---------| 
    | bit8    | bit8    |
    | bit16   | bit16   |
    | bit32   | bit32   |
  }];

  let arguments = (ins
    LLNIR_Tensor:$input1,
    LLNIR_Tensor:$input2
  );

  let results = (outs
    LLNIR_Tensor:$output
  );

  let assemblyFormat = "operands attr-dict `:` functional-type(operands, results)";
}

//===----------------------------------------------------------------------===//
// Operator: bitwise_or
//===----------------------------------------------------------------------===//
def LLNIR_BitwiseOrOp : LLNIR_ElementwiseOp<"bitwise_or", [
    Commutative,
    SameOperandsAndResultElementType]> {
  let summary = "Bitwise OR operator.";

  let description = [{
    Elementwise bitwise OR of input1 and input2. Axis of size 1 will be
    broadcast as necessary. Rank of input tensors must match.
  }];

  let arguments = (ins
    LLNIR_Tensor:$input1,
    LLNIR_Tensor:$input2
  );

  let results = (outs
    LLNIR_Tensor:$output
  );

  let assemblyFormat = "operands attr-dict `:` functional-type(operands, results)";
}

//===----------------------------------------------------------------------===//
// Operator: bitwise_xor
//===----------------------------------------------------------------------===//
def LLNIR_BitwiseXorOp : LLNIR_ElementwiseOp<"bitwise_xor", [
    Commutative,
    SameOperandsAndResultElementType]> {
  let summary = "Bitwise XOR operator.";

  let description = [{
    Elementwise bitwise XOR of input1 and input2. Axis of size 1 will be
    broadcast as necessary. Rank of input tensors must match.
  }];

  let arguments = (ins
    LLNIR_Tensor:$input1,
    LLNIR_Tensor:$input2
  );

  let results = (outs
    LLNIR_Tensor:$output
  );

  let assemblyFormat = "operands attr-dict `:` functional-type(operands, results)";
}

//===----------------------------------------------------------------------===//
// Operator: bitwise_not
//===----------------------------------------------------------------------===//
def LLNIR_BitwiseNotOp : LLNIR_ElementwiseOp<"bitwise_not", [
    Commutative,
    SameOperandsAndResultElementType]> {
  let summary = "Bitwise NOT operator.";

  let description = [{
    Elementwise bitwise NOT of input1. 
  }];

  let arguments = (ins
    LLNIR_Tensor:$input1
  );

  let results = (outs
    LLNIR_Tensor:$output
  );

  let assemblyFormat = "operands attr-dict `:` functional-type(operands, results)";
}

//===----------------------------------------------------------------------===//
// Operator: left_shift
//===----------------------------------------------------------------------===//
def LLNIR_LeftshiftOp : LLNIR_ElementwiseOp<"left_shift", [
    Commutative,
    SameOperandsAndResultElementType]> {
  let summary = "Bitwise left shift operator.";

  let description = [{
    Elementwise bitwise left-shift of input1 and input2. Axis of size 1 will be
    broadcast as necessary. Rank of input tensors must match.
  }];

  let arguments = (ins
    LLNIR_Tensor:$input1,
    LLNIR_Tensor:$input2
  );

  let results = (outs
    LLNIR_Tensor:$output
  );

  let assemblyFormat = "operands attr-dict `:` functional-type(operands, results)";
}

//===----------------------------------------------------------------------===//
// Operator: right_shift   TODO:yswang
//===----------------------------------------------------------------------===//
def LLNIR_RightshiftOp : LLNIR_ElementwiseOp<"right_shift", [
    Commutative,
    SameOperandsAndResultElementType]> {
  let summary = "Bitwise right shift operator.";

  let description = [{
    Elementwise bitwise right-shift of input1 and input2. Axis of size 1 will be
    broadcast as necessary. Rank of input tensors must match.
  }];

  let arguments = (ins
    LLNIR_Tensor:$input1,
    LLNIR_Tensor:$input2
  );

  let results = (outs
    LLNIR_Tensor:$output
  );

  let assemblyFormat = "operands attr-dict `:` functional-type(operands, results)";
}

//===----------------------------------------------------------------------===//
// Operator: negative
//===----------------------------------------------------------------------===//
def LLNIR_NegativeOp : LLNIR_ElementwiseOp<"negative", [
    LLNIRElementwiseOperator,
    Pure]> {
  let summary = "Elementwise negative operator.";

  let description = [{
    Elementwise negative operation.

    precision supported:
    |Input    |Ouput    |
    |---------|---------| 
    | bit8    | bit8    |
    | bit16   | bit16   |
    | bit32   | bit32   |
    | fp16    | fp16   |
    | fp32    | fp32   |

  }];

  let arguments = (ins
      LLNIR_Tensor:$input1
  );

  let results = (outs
    LLNIR_Tensor:$output
  );

  //let builders = [LLNIR_NegateOpQuantInfoBuilder];

  //let hasFolder = 1;
  //let hasVerifier = 1;

  let assemblyFormat =
      "operands attr-dict `:` functional-type(operands, results)";
}

//===----------------------------------------------------------------------===//
// Operator: quant TODO:yswang
//===----------------------------------------------------------------------===//
def LLNIR_QuantOp : LLNIR_ElementwiseOp<"quant", [
    LLNIRElementwiseOperator,
    Pure]> {
  let summary = "Elementwise quant operator.";

  let description = [{
    Elementwise quant operation.

    precision supported:

    |Input    |Ouput    |
    |---------|---------| 
    | fp16    | int8    |
    | fp16    | int16   |
    | fp32    | int8    |
    | fp32    | int16   |

  }];

  let arguments = (ins
      LLNIR_Tensor:$input1,
      LLNIR_ScalarIntOrFloatTensor:$input_zp,
      LLNIR_ScalarIntOrFloatTensor:$input_scale,
      DenseI64ArrayAttr:$axis,
      DenseI64ArrayAttr:$block_size
  );

  let results = (outs
    LLNIR_Tensor:$output
  );

  //let builders = [LLNIR_NegateOpQuantInfoBuilder];

  //let hasFolder = 1;
  //let hasVerifier = 1;

  let assemblyFormat =
      "operands attr-dict `:` functional-type(operands, results)";
}

//===----------------------------------------------------------------------===//
// Operator: dequant TODO:yswang
//===----------------------------------------------------------------------===//
def LLNIR_DequantOp : LLNIR_ElementwiseOp<"dequant", [
    LLNIRElementwiseOperator,
    Pure]> {
  let summary = "Elementwise dequant operator.";

  let description = [{
    Elementwise dequant operation.

    precision supported:

    |Input    |Ouput    |
    |---------|---------| 
    | int8    | fp16    |
    | int8    | fp32    |
    | int16   | fp16    |
    | int16   | fp32    |

  }];

  let arguments = (ins
      LLNIR_Tensor:$input1,
      LLNIR_ScalarIntOrFloatTensor:$input_zp,
      LLNIR_ScalarIntOrFloatTensor:$input_scale,
      DenseI64ArrayAttr:$axis,
      DenseI64ArrayAttr:$block_size
  );

  let results = (outs
    LLNIR_Tensor:$output
  );

  //let builders = [LLNIR_NegateOpQuantInfoBuilder];

  //let hasFolder = 1;
  //let hasVerifier = 1;

  let assemblyFormat =
      "operands attr-dict `:` functional-type(operands, results)";
}


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


def LLNIR_FooOp : LLNIR_Op<"foo", [Pure,
                                             SameOperandsAndResultType]> {
    let summary = "Illustrates how to define an operation.";
    let description = [{
        The `llnir.foo` operation illustrates how to define a new
        operation in a dialect. It uses an operation trait to declare that it
        has no side effects.

        This operation takes an integer argument and returns an integer.

        Example:

        ```mlir
        %0 = arith.constant 2 : i32
        // Apply the foo operation to %0
        %1 = llnir.foo %0 : i32
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

def LLNIR_AddOp: LLNIR_ElementwiseOp<"add", [ 
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
    %out = llnir.add %input1, %input2 : tensor<12x6xf32>, tensor<12x6xf32> -> tensor<12x6xf32>

    // Elementwise addition with broadcasting.
    %out = llnir.add %input1, %input2 : tensor<12x6xsi32>, tensor<1x1xsi32> -> tensor<12x6xsi32>
    ```
  }];

  let arguments = (ins
    LLNIR_Tensor:$input1,
    LLNIR_Tensor:$input2
  );

  let results = (outs 
    LLNIR_Tensor:$output
  );
  //let hasCanonicalizer = 1;
  let hasFolder = 1;
  //let hasCustomAssemblyFormat = 1;
  //let assemblyFormat = "operands attr-dict `:` functional-type(operands, results)";
}
 
//===----------------------------------------------------------------------===//
// Operator: mul
//===----------------------------------------------------------------------===//
def LLNIR_MulOp : LLNIR_Op<"mul", [
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
    LLNIR_Tensor:$input1,
    LLNIR_Tensor:$input2
    // Apply right shift on i32_t input data only
    //LLNIR_ScalarInt8Tensor:$shift
  );

  let results = (outs
    LLNIR_Tensor:$output
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
 
def LLNIR_ConstOp : LLNIR_Op<"const", [ConstantLike, Pure,
                                      AllShapesMatch<["values", "output"]>,
                                      FirstAttrDerivedResultType]> {
  let summary = "Constant operator.";

  let description = [{
    A node containing constant data for use as the input to an operation. May
    hold data in any of the supported data formats.

    Example:

    ```mlir
    // Generic form
    %out = "llnir.const"() {values = dense<0> : tensor<2x3xi32>} : () -> tensor<2x3xi32>
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
def LLNIR_Conv2DOp : LLNIR_ConvOp<"conv2d"> {
  let summary = "2D Convolution operator.";

  let description = [{
    Performs a 2D convolution over the given tensor input, using the weight
    tensor. Implementations may choose to skip calculation of multiplies in
    the padding area.
  }];

  let arguments = (ins
    LLNIR_Tensor4D:$input,
    LLNIR_Tensor4D:$weight,
    LLNIR_Tensor1D:$bias,
    LLNIR_ScalarIntOrFloatTensor:$input_zp,
    LLNIR_ScalarIntOrFloatTensor:$weight_zp,

    LLNIR_IntArrayAttr4:$pad,
    LLNIR_IntArrayAttr2:$stride,
    LLNIR_IntArrayAttr2:$dilation,
    //TypeAttrOf<LLNIR_AccType>:$acc_type,
    DefaultValuedOptionalAttr<BoolAttr, "false">:$local_bound
  );

  let results = (outs
    LLNIR_Tensor4D:$output
  );

  //let builders = [LLNIR_ConvOpQuantInfoBuilder];

  //let hasCanonicalizer = 1;
  //let hasVerifier = 1;
}

//===----------------------------------------------------------------------===//
// Operator: matmul
//===----------------------------------------------------------------------===//
def LLNIR_MatMulOp : LLNIR_InferShapedTypeOp<"matmul"> {
  let summary = "Matrix multiplication operator.";

  let description = [{
    Performs two dimensional matrix multiplications.
  }];

  let arguments = (ins
    LLNIR_Tensor3D:$a,
    LLNIR_Tensor3D:$b
  );

  let results = (outs
    LLNIR_Tensor3D:$output
  );

  //let builders = [LLNIR_ConvOpQuantInfoBuilder];

  //let hasCanonicalizer = 1;
  //let hasVerifier = 1;
}

#endif // MLIR_DIALECT_LLNIR_IR_LLNIROPS_TD
