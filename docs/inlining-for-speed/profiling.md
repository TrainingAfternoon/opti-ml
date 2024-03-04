# Setting up profiling
## Background
* [Instrumentation profiling](https://clang.llvm.org/docs/UsersManual.html#profiling-with-instrumentation)

## Prerequisites
LLVM built
```bash
./build_llvm.sh
```

## Demoing on no-more-secrets
Install [no-more-secrets](https://github.com/bartobri/no-more-secrets)

Add `-fprofile-generate` to `cflags`

Set the profile file
```bash
export LLVM_PROFILE_FILE="code-%m.profraw
```

Make the sneakers module
```bash
make sneakers
```

Run the code to produce the profiling file
```bash
bin/sneakers
```
