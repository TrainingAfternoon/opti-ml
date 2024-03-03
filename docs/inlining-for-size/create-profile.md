# Setting up profiling
## Background
* [Instrumentation profiling](https://clang.llvm.org/docs/UsersManual.html#profiling-with-instrumentation)

## Prerequisites
LLVM built
```bash
./build_llvm.sh
```

Make [compiler-rt](https://compiler-rt.llvm.org/) for LLVM clang
```bash
cd llvm-project
mkdir build-compiler-rt
cd build-compiler-rt
cmake ../compiler-rt -DLLVM_CMAKE_DIR=/path/to/llvm-project/cmake/modules
make
```

Install it system-wide (need to be in build-compiler-rt)
```bash
sudo make install
```

## Demoing on no-more-secrets
Install [no-more-secrets](https://github.com/bartobri/no-more-secrets)

Add `-fprofile-generate=$(BIN)/$@` to build invocation for `sneakers`

Make the sneakers module
```bash
make sneakers
```
