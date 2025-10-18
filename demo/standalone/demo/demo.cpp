//===- standalone-translate.cpp ---------------------------------*- C++ -*-===//
//
// This file is licensed under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This is a command line utility that translates a file from/to MLIR using one
// of the registered translations.
//
//===----------------------------------------------------------------------===//

#include "Standalone/StandaloneDialect.h"
#include "mlir/IR/DialectRegistry.h"
#include "mlir/IR/Operation.h"
#include "mlir/InitAllTranslations.h"
#include "mlir/Tools/mlir-translate/MlirTranslateMain.h"
#include "mlir/Tools/mlir-translate/Translation.h"
#include "llvm/Support/raw_ostream.h"

#include "mlir/IR/BuiltinAttributes.h"
#include "mlir/IR/MLIRContext.h"
#include "mlir/IR/AsmState.h"
#include <fstream>
#include <vector>

using namespace mlir;

DenseResourceElementsAttr createDenseResourceAttrFromVector(
  MLIRContext *context,
  ShapedType type,
  const std::vector<char>& buffer) { 
  // Create the AsmResourceBlob
  //auto blob = AsmResourceBlob::get(context, buffer);
  AsmResourceBlob::DeleterFn cppDeleter = {};
  AsmResourceBlob blob(
      llvm::ArrayRef(buffer.data(), buffer.size()),
      8, std::move(cppDeleter), true);
  llvm::outs() << "Buffer contents:\n";
  // Create the DenseResourceElementsAttr
  return DenseResourceElementsAttr::get(type, "file_blob", std::move(blob));
}

DenseResourceElementsAttr createDenseResourceAttrFromFile(
  MLIRContext *context,
  ShapedType type,
  const std::string &filePath, const std::vector<char>& buffer2) {  
  // Read the file content
  std::ifstream file(filePath, std::ios::binary);
  if (!file.is_open()) {
    llvm::errs() << "Failed to open file: " << filePath << "\n";
    return nullptr;
  }                
  // Read file content into a buffer 
  std::vector<char> buffer((std::istreambuf_iterator<char>(file)),
                            std::istreambuf_iterator<char>());

  llvm::outs() << "Read buffer contents:\n";
  for (auto it : buffer) {
    llvm::outs() << static_cast<int>(it) << "\n";
  }
  file.close();
  // Create the AsmResourceBlob
  //auto blob = AsmResourceBlob::get(context, buffer);
  AsmResourceBlob::DeleterFn cppDeleter = {};
  AsmResourceBlob blob(
      llvm::ArrayRef(buffer.data(), buffer.size()),
      8, std::move(cppDeleter), true);
    llvm::outs() << "Read buffer contents:\n";
    for (auto it : buffer) {
      llvm::outs() << static_cast<int>(it) << "\n";
    }
  // Create the DenseResourceElementsAttr
  return DenseResourceElementsAttr::get(type, "file_blob", std::move(blob));
}

void writeDenseResourceAttrToFile(
  DenseResourceElementsAttr attr, 
  const std::string &filePath
) {
  // Get the data from the attribute
  ArrayRef<char> data = attr.getData();

  // Open the file for writing
  std::ofstream file(filePath, std::ios::binary);
  if (!file.is_open()) {
    llvm::errs() << "Failed to open file: " << filePath << "\n";
    return;
  }

  // Write the data to the file
  file.write(data.data(), data.size());
  file.close();
}

static void testDenseResourceAttr()
{
  MLIRContext context;
  auto type = RankedTensorType::get({8}, IntegerType::get(&context, 8));

  {
    std::vector<char> buffer = {1,2,3,4,5,6,7,8};
    auto attr = createDenseResourceAttrFromVector(&context, type, buffer);
    llvm::outs() << "Created DenseResourceElementsAttr from vector:\n";
    attr.dump();
    for (auto it : attr.getData()) {
      llvm::outs() << static_cast<int>(it) << "\n";
    }

    writeDenseResourceAttrToFile(attr, "output.bin");

    // 下面结果有问题
    attr = createDenseResourceAttrFromFile(&context, type, "output.bin", buffer);
    if (!attr) {
      llvm::errs() << "Failed to create DenseResourceElementsAttr from file.\n";
      return;
    }

    llvm::outs() << "Read DenseResourceElementsAttr from file:\n";
    attr.dump();
    for (auto it : attr.getData()) {
      llvm::outs() << static_cast<int>(it) << "\n";
    }
  }
}



int main(int argc, char **argv) {
  testDenseResourceAttr();
  return 0;
  // mlir::registerAllTranslations();

  // // TODO: Register standalone translations here.
  // mlir::TranslateFromMLIRRegistration withdescription(
  //     "option", "different from option",
  //     [](mlir::Operation *op, llvm::raw_ostream &output) {
  //       return llvm::LogicalResult::success();
  //     },
  //     [](mlir::DialectRegistry &a) {});

  // return failed(
  //     mlir::mlirTranslateMain(argc, argv, "MLIR Translation Testing Tool"));
}
