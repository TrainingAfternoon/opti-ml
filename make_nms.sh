#!/usr/bin/env bash

# NOTE: must add -fembed-bitcode=all -save-temps=obj to CCFLAGS in Makefile under no-more-secrets

source .env
export CC=$LLVM_INSTALLDIR/bin/clang

cd $HOME/no-more-secrets
make clean
bear -- make nms
