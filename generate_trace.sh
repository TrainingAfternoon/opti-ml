#!/usr/bin/env bash

source .env
source $VENVPATH/bin/activate

echo "PYTHONPATH=$PYTHONPATH"

rm $DEFAULT_TRACE

pipenv run python3 compiler_opt/tools/generate_default_trace.py \
	--data_path=$CORPUS \
	--output_path=$DEFAULT_TRACE \
	--gin_files=compiler_opt/rl/inlining/gin_configs/common.gin \
	--gin_bindings=config_registry.get_configuration.implementation=@configs.InliningConfig \
	--gin_bindings=clang_path="'$LLVM_INSTALLDIR/bin/clang'" \
	--gin_bindings=llvm_size_path="'$LLVM_INSTALLDIR/bin/llvm-size'" \
	--sampling_rate=1.0

deactivate
