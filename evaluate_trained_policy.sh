#!/usr/bin/env bash

# environment set up
## import common environment variables
source .env

## activate virtualenv
source $VENVPATH/bin/activate

  #--compile_task=inlining \

pipenv run python3 compiler_opt/tools/generate_default_trace.py \
  --data_path=$CORPUS \
  --policy_path=$OUTPUT_DIR/saved_policy \
  --output_performance_path=$OUTPUT_PERFORMANCE_PATH \
  --gin_files=compiler_opt/rl/inlining/gin_configs/common.gin \
  --gin_bindings=clang_path="'$LLVM_INSTALLDIR/bin/clang'" \
  --gin_bindings=llvm_size_path="'$LLVM_INSTALLDIR/bin/llvm-size'" \
  --sampling_rate=1.0 # NOTE: this was modified from their value of 0.2

deactivate
