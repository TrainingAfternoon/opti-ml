#!/usr/bin/env bash

echo "Sourcing .env and venvpath"
source .env
source $VENVPATH/bin/activate

# NOTE: MAKE SURE THAT LLVM IS CLONED TO LLVM_SRCDIR!

# install dependencies
echo "Installing LLVM dependencies"
#sudo apt-get install ninja-build lld

# tensorflow stuff
echo "Doing the tensorflow stuff"
#sudo apt-get install ccache libxml2-dev automake libpthreadpool-dev
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
## https://lists.llvm.org/pipermail/llvm-dev/2020-April/140763.html
echo "Building LLVM"
cd $RANDOM_LLVM_SRCDIR
mkdir -p $RANDOM_LLVM_INSTALLDIR
cd $RANDOM_LLVM_INSTALLDIR
cmake \
	-G "Ninja" \
	-S $RANDOM_LLVM_SRCDIR/llvm \
	-DLLVM_ENABLE_PROJECTS='clang' \
	-DCMAKE_INSTALL_PREFIX='~/workspace/llvm-install' \
	-DCMAKE_BUILD_TYPE='Release' \
	-DLLVM_USE_ML_POLICY='Rel' \
	-DLLVM_TF_AOT_RUNTIME=$TENSORFLOW_AOT_PATH \
	-DLLVM_USE_LINKER=lld \
	-DLLVM_ENABLE_RUNTIMES="compiler-rt" \
	-C ${TFLITE_PATH}/tflite.cmake
cmake --build .

echo "Done"
deactivate
