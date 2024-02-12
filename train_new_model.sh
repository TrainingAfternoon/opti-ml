#!/usr/bin/env bash

# NOTE: this assumes that train_warmstart_model.sh has been run first

# environment set up
## import common environment variables
source .env

## activate virtualenv
source $VENVPATH/bin/activate

# train the model
rm -rf $OUTPUT_DIR
compiler_opt/rl/train_locally.py \
  --root_dir=$OUTPUT_DIR \
  --data_path=$CORPUS \
  --gin_bindings=clang_path="'$LLVM_INSTALLDIR/bin/clang'" \
  --gin_bindings=llvm_size_path="'$LLVM_INSTALLDIR/bin/llvm-size'" \
  --gin_files=compiler_opt/rl/inlining/gin_configs/ppo_nn_agent.gin \
  --gin_bindings=train_eval.warmstart_policy_dir=\"$WARMSTART_OUTPUT_DIR/saved_policy\"
