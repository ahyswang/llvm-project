#ifndef LLNIR_REGISTERALL_H
#define LLNIR_REGISTERALL_H

namespace mlir {
    class DialectRegistry;
} // namespace mlir

namespace mlir::lln_mlir {
    void registerAllDialects(mlir::DialectRegistry &registry);
    void registerAllExtensions(mlir::DialectRegistry &registry);
    void registerAllPasses();
} // namespace mlir::lln_mlir

#endif // LLNIR_REGISTERALL_H