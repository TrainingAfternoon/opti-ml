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
echo "Building LLVM"
cd $LLVM_SRCDIR
mkdir -p build
cd build
cmake \
  -G "Ninja" \
  -DLLVM_ENABLE_PROJECTS='clang' \
  -DLLVM_USE_LINKER=lld \
  -DLLVM_ENABLE_LTO=OFF \
  -DLINUX_x86_64-unknown-linux-gnu_SYSROOT=${SYSROOT_DIR}/linux-x64 \
  -DLINUX_aarch64-unknown-linux-gnu_SYSROOT=${SYSROOT_DIR}/linux-arm64 \
  -DFUCHSIA_SDK=${IDK_DIR} \
  -DCMAKE_INSTALL_PREFIX= \
  -DCMAKE_INSTALL_RPATH_USE_LINK_PATH=On \
  -C ${LLVM_SRCDIR}/clang/cmake/caches/Fuchsia-stage2.cmake \
  -C ${TFLITE_PATH}/tflite.cmake \
  ${LLVM_SRCDIR}/llvm

# fuchsia specific stuff
ninja toolchain-distribution
DESTDIR=${LLVM_INSTALLDIR} ninja install-toolchain-distribution-stripped
cd ${FUCHSIA_SRCDIR}
python3 scripts/clang/generate_runtimes.py --clang-prefix=$LLVM_INSTALLDIR --sdk-dir=$IDK_DIR --build-id-dir=$LLVM_INSTALLDIR/lib/.build-id > $LLVM_INSTALLDIR/lib/runtime.json

echo "Done"
deactivate
