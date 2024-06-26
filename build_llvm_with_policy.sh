#!/usr/bin/env bash

# build a release version of LLVM with policy embedded

echo "Sourcing .env and venvpath"
source .env
source $VENVPATH/bin/activate

# allow for choosing model path
if [ ! -z "$1" ]
then
    POLICY_DIR="${1}"
else
    POLICY_DIR="${OUTPUT_DIR}/saved_policy"
fi
echo "Using POLICY_DIR=${POLICY_DIR}"

# NOTE: MAKE SURE THAT LLVM IS CLONED TO LLVM_SRCDIR!
# cd ${LLVM_SRCDIR} && git clone https://github.com/llvm/llvm-project.git
# cd ${LLVM_SRCDIR} && git checkout fa4c3f70ff0768a270b0620dc6d158ed1205ec4e

# tensorflow stuff
echo "Doing the tensorflow stuff"
TF_PIP=$(python3 -m pip show tensorflow | grep Location | cut -d ' ' -f 2)

export TENSORFLOW_AOT_PATH="${TF_PIP}/tensorflow"
export TFLITE_PATH=$HOME/tflite

# build the LLVM build scripts
## RESOURCES:
## https://llvm.org/docs/GettingStarted.html#hardware
## https://llvm.org/docs/GettingStarted.html#getting-the-source-code-and-building-llvm
## https://llvm.org/docs/CMake.html#cmake-build-type
## https://lists.llvm.org/pipermail/llvm-dev/2020-April/140763.html

## start build process
echo "Building LLVM"
cd $LLVM_SRCDIR

## move over policy
cd $LLVM_SRCDIR
rm -rf ./llvm/lib/Analysis/models/inliner/*
mkdir -p ./llvm/lib/Analysis/models/inliner/
cp -rf $POLICY_DIR/* ./llvm/lib/Analysis/models/inliner/

## make build directory
mkdir -p $LLVM_INSTALLDIR
cd $LLVM_INSTALLDIR

## perform build
cmake \
	-G "Ninja" \
	-S $LLVM_SRCDIR/llvm \
	-C ${TFLITE_PATH}/tflite.cmake \
	-DCMAKE_BUILD_TYPE='Release' \
	-DLLVM_ENABLE_PROJECTS='clang' \
	-DCMAKE_INSTALL_PREFIX='${LLVM_INSTALLDIR}' \
	-DLLVM_USE_ML_POLICY='Rel' \
	-DLLVM_TF_AOT_RUNTIME=$TENSORFLOW_AOT_PATH \
	-DLLVM_USE_LINKER=lld \
    -DLLVM_ENABLE_LTO=OFF
cmake --build .

echo "Done"
deactivate
