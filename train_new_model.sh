#!/usr/bin/env bash

# NOTE: this assumes that train_warmstart_model.sh has been run first

# environment set up
## import common environment variables
source .env

## activate virtualenv
source $VENVPATH/bin/activate

## fix an issue with the policysaver
## https://github.com/GrahamDumpleton/wrapt/issues/231
export WRAPT_DISABLE_EXTENSIONS=true

# train the model
OUTPUT_DIR=$_HOME/test-model
rm -rf $OUTPUT_DIR
mkdir -p $OUTPUT_DIR
pipenv run python3 compiler_opt/rl/train_locally.py \
  --root_dir=$OUTPUT_DIR \
  --data_path=$CORPUS \
  --gin_bindings=clang_path="'$LLVM_INSTALLDIR/bin/clang'" \
  --gin_bindings=llvm_size_path="'$LLVM_INSTALLDIR/bin/llvm-size'" \
  --gin_bindings=ir2perf_model_pickle_path="'$_HOME/xgboost-rf-model.pickle'" \
  --gin_bindings=ir2vec_path="'$_HOME/workspace/IR2Vec/build/bin/ir2vec'" \
  --gin_bindings=ir2vec_vocab_path="'$_HOME/workspace/IR2Vec/vocabulary/seedEmbeddingVocab.txt'" \
  --gin_files=compiler_opt/rl/inlining/gin_configs/ppo_nn_agent.gin \
  --gin_bindings=train_eval.warmstart_policy_dir=\"$WARMSTART_OUTPUT_DIR/saved_policy\"
