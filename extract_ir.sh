#!/usr/bin/env bash

source .env
source $VENVPATH/bin/activate

echo "PYTHONPATH=$PYTHONPATH"
echo "PWD=$PWD"

#rm -rf $DEFAULT_TRACE 

pipenv run python3 compiler_opt/tools/extract_ir.py \
  --cmd_filter="^-O2|-Os|-Oz$" \
  --input=$NMS_SRCDIR/compile_commands.json \
  --input_type=json \
  --llvm_objcopy_path=$LLVM_INSTALLDIR/bin/llvm-objcopy \
  --output_dir=$CORPUS 

deactivate
