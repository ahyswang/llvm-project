#!/bin/bash 

export PATH=$PWD/../../build_debug/bin/:$PATH

llvm-lit ./ -v