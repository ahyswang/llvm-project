//===- GeLU.cpp -----------------------------------------------*--- C++ -*-===//
//
// Copyright 2022 ByteDance Ltd. and/or its affiliates. All rights reserved.
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
//===----------------------------------------------------------------------===//

#include "llnmlir/Dialect/LLNIR/Register/Register.h"
#include "llnmlir/Dialect/LLNIR/Utils/ShapeInferUtil.h"
#include "llnmlir/Dialect/LLNIR/IR/LLNIR.h"

#include "mlir/Dialect/Shape/IR/Shape.h"
#include "mlir/Dialect/Tensor/IR/Tensor.h"
#include "mlir/IR/Builders.h"
#include "mlir/IR/BuiltinTypes.h"
#include "llvm/Support/Debug.h"

#define DEBUG_TYPE "dynamic-shape-op-register"

using namespace mlir;

void mlir::registerMatMulReifyReturnTypeShapes() {
  static ReifyReturnTypeShapesRegistration shapeRegister(
    getMatMulName(), [](Operation *op, OpBuilder &builder, ValueRange operands,
                        SmallVectorImpl<::mlir::Value> &reifiedReturnShapes) {
        // Value dataShape =
        //     builder.create<shape::ShapeOfOp>(op->getLoc(), operands[0]);
        // reifiedReturnShapes.push_back(dataShape);
        auto matmulOp = dyn_cast<llnir::MatMulOp>(op);
        auto lhsType = dyn_cast<ShapedType>(matmulOp.getA().getType());
        auto rhsType = dyn_cast<ShapedType>(matmulOp.getB().getType());
        if (!lhsType || !rhsType || !lhsType.hasRank() || !rhsType.hasRank()) {
          return failure();
        }
        if (lhsType.getRank() != 3 || rhsType.getRank() != 3) {
          return failure();
        } 
        if (lhsType.getDimSize(0) != rhsType.getDimSize(0)) {
          return failure();
        }   

        llnir::MatMulOp::Adaptor adaptor(operands);
        auto lhs = adaptor.getA();
        auto rhs = adaptor.getB();
        SmallVector<Value> dimensions(3);

        // Batch dimensions 
        dimensions[0] = builder.create<tensor::DimOp>(op->getLoc(), lhs, 0);
        dimensions[1] = builder.create<tensor::DimOp>(op->getLoc(), lhs, 1);
        dimensions[2] = builder.create<tensor::DimOp>(op->getLoc(), rhs, 2);
        
        reifiedReturnShapes.push_back(
            builder.create<tensor::FromElementsOp>(op->getLoc(), dimensions));

        return success();
      });
}
