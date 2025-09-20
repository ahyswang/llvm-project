#!/bin/bash 

../build/bin/mlir-opt --tosa-infer-shapes demo.mlir -o -
