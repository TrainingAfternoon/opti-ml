#!/usr/bin/env bash
# Reference: https://github.com/TrainingAfternoon/opti-ml/blob/main/docs/inlining-demo/demo.md#extract-the-corpus
# NOTE: may need to be run with sudo because of a weird bug with llvm-objcopy not
#       having permissions for input files when run with --dump-sections?

source .env
source $VENVPATH/bin/activate

# path to built repository
# TODO: make this a param in the future???
INPUTPATH=$_HOME/no-more-secrets

echo "Running extract_ir.py"
#docker run --mount type=bind,source=$_HOME,target=$_HOME --platform="linux/amd64" --rm mlgo python3 extract_ir.py \
#  --cmd_filter="^-O2|-Os|-Oz$" \
#  --input=$INPUTPATH/compile_commands.json \
#  --input_type=json \
#  --llvm_objcopy_path=$LLVM_INSTALLDIR/bin/llvm-objcopy \
#  --output_dir=$CORPUS

export PYTHONPATH=$PYTHONPATH:.
python3 compiler_opt/tools/extract_ir.py \
  --cmd_filter="^-O2|-Os|-Oz$" \
  --input=$INPUTPATH/compile_commands.json \
  --input_type=json \
  --llvm_objcopy_path=$LLVM_INSTALLDIR/bin/llvm-objcopy \
  --output_dir=$CORPUS \
  --verbosity 0

chown -R student:student $CORPUS

echo "Done"
deactivate

