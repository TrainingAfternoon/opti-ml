#!/usr/bin/env bash

# NOTE: crispy-doom has some 1-time set up which must be performed, details here:
#       https://github.com/fabiangreffrath/crispy-doom/wiki/Building-on-Linux

# NOTE 2: must add -fembed-bitcode=all -save-temps=obj to CCFLAGS in Makefile under crispy-doom

source .env
export CC=$LLVM_INSTALLDIR/bin/clang

cd $HOME/crispy-doom
make clean
bear -- make
