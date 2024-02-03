#!/usr/bin/env bash

echo "Sourcing .env and venvpath"
source .env
source $VENVPATH/bin/activate

# NOTE: MAKE SURE THAT LLVM IS CLONED TO LLVM_SRCDIR!

# install dependencies
echo "Installing LLVM dependencies"
sudo apt-get install ninja-build lld

# tensorflow stuff
echo "Doing the tensorflow stuff"
sudo apt-get install ccache gcc-multilib g++-multilib libxml2-dev automake libpthreadpool-dev
TF_PIP=$(python3 -m pip show tensorflow | grep Location | cut -d ' ' -f 2)

export TENSORFLOW_AOT_PATH="${TF_PIP}/tensorflow"
export TFLITE_PATH=$HOME/tflite
mkdir ${TFLITE_PATH}

cd ${TFLITE_PATH}
$OPTIML_SRCDIR/buildbot/build_tflite.sh

# build the LLVM build scripts
## RESOURCES:
## https://llvm.org/docs/GettingStarted.html#hardware
## https://llvm.org/docs/GettingStarted.html#getting-the-source-code-and-building-llvm
## https://llvm.org/docs/CMake.html#cmake-build-type
#echo "Building LLVM"
#cd $LLVM_SRCDIR
#mkdir -p build
#cd build
#cmake \
#	-G "Ninja" \
#	-S $LLVM_SRCDIR/llvm \
#	-DLLVM_ENABLE_PROJECTS='clang' \
#	-DCMAKE_INSTALL_PREFIX='~/workspace/llvm-install' \
#	-DCMAKE_BUILD_TYPE='Debug' \
#	-DLLVM_USE_LINKER=lld \
#	-C ${TFLITE_PATH}/tflite.cmake  \
#ninja check-llvm clang

echo "Done"
deactivate
