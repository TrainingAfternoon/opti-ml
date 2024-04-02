# TODO: change this location to where-ever you want the IR2Vec & associated dependencies deposited!
INSTALL_DIR=$HOME
cd $INSTALL_DIR

# checkout IR2vec
git clone git@github.com:IITH-Compilers/IR2Vec.git
cd IR2Vec
git checkout 3e2f3afaf71f79ef40a4edf4ba3e8048949aef2e # version we used

# build IR2Vec from source
## we had to do this b/c we used an arm architecture, and IR2Vec does not build
## for ARM by default

## get LLVM
cd ..
wget https://github.com/llvm/llvm-project/releases/download/llvmorg-17.0.1/clang+llvm-17.0.1-aarch64-linux-gnu.tar.xz
unxz clang+llvm-17.0.1-aarch64-linux-gnu.tar.xz
tar xvf clang+llvm-17.0.1-aarch64-linux-gnu.tar
rm clang+llvm-17.0.1-aarch64-linux-gnu.tar

## get eigen
wget https://gitlab.com/libeigen/eigen/-/archive/3.3.7/eigen-3.3.7.tar.gz
gunzip eigen-3.3.7.tar.gz
tar xvf eigen-3.3.7.tar
rm eigen-3.3.7.tar

## generate make files for IR2vec
cd IR2Vec
mkdir build && cd build
cmake \
    -DLT_LLVM_INSTALL_DIR=$INSTALL_DIR/clang+llvm-17.0.1-aarch64-linux-gnu/ \
    -DEigen3_DIR=$INSTALL_DIR/eigen-build/ \
    ..
make
