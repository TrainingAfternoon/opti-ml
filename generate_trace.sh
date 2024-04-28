#!/usr/bin/env bash

source .env
source $VENVPATH/bin/activate

echo "PYTHONPATH=$PYTHONPATH"

rm $DEFAULT_TRACE

pipenv run python3 compiler_opt/tools/generate_default_trace.py \
	--data_path=$CORPUS \
	--output_path=$DEFAULT_TRACE \
	--gin_files=compiler_opt/rl/inlining/gin_configs/common.gin \
	--gin_bindings=ir2perf_model_pickle_path="'$_HOME/xgboost-rf-model.pickle'" \
	--gin_bindings=ir2vec_path="'$_HOME/workspace/IR2Vec/build/bin/ir2vec'" \
	--gin_bindings=ir2vec_vocab_path="'$_HOME/workspace/IR2Vec/vocabulary/seedEmbeddingVocab.txt'" \
	--gin_bindings=config_registry.get_configuration.implementation=@configs.InliningConfig \
	--gin_bindings=clang_path="'$LLVM_INSTALLDIR/bin/clang'" \
	--gin_bindings=llvm_size_path="'$LLVM_INSTALLDIR/bin/llvm-size'" \
	--sampling_rate=1.0 # NOTE: this was modified from their value of 0.2

deactivate
