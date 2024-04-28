#!/usr/bin/env bash

# environment set up
## import common environment variables
source .env

## activate virtualenv
source $VENVPATH/bin/activate

## fix an issue with the policysaver
## https://github.com/GrahamDumpleton/wrapt/issues/231
export WRAPT_DISABLE_EXTENSIONS=true

# Train behavioral cloning model based on generated trace
# Mimics default inlining behavior
rm -rf $WARMSTART_OUTPUT_DIR
pipenv run python3 compiler_opt/rl/train_bc.py \
  --root_dir=$WARMSTART_OUTPUT_DIR \
  --gin_bindings=clang_path="'$LLVM_INSTALLDIR/bin/clang'" \
  --gin_bindings=llvm_size_path="'$LLVM_INSTALLDIR/bin/llvm-size'" \
  --gin_bindings=ir2perf_model_pickle_path="'$_HOME/xgboost-rf-model.pickle'" \
  --gin_bindings=ir2vec_path="'$_HOME/workspace/IR2Vec/build/bin/ir2vec'" \
  --gin_bindings=ir2vec_vocab_path="'$_HOME/workspace/IR2Vec/vocabulary/seedEmbeddingVocab.txt'" \
  --data_path=$DEFAULT_TRACE \
  --gin_files=compiler_opt/rl/inlining/gin_configs/behavioral_cloning_nn_agent.gin
