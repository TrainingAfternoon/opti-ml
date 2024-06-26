# coding=utf-8
# Copyright 2020 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
"""Module for collect data of inlining-for-size."""

import os
import tempfile
from typing import Dict, Tuple

import gin
import tensorflow as tf

# IR2Perf Requirements
import pickle
from xgboost import XGBRFRegressor
from sklearn.pipeline import Pipeline
from sklearn.decomposition import PCA
from sklearn.preprocessing import StandardScaler

from compiler_opt.rl import compilation_runner
from compiler_opt.rl import corpus
from compiler_opt.rl import log_reader

_DEFAULT_IDENTIFIER = 'default'


@gin.configurable(module='runners')
class InliningRunner(compilation_runner.CompilationRunner):
  """Class for collecting data for inlining-for-size.

  Usage:
  inliner = InliningRunner(
                clang_path, llvm_size_path, launcher_path,
                moving_average_decay_rate)
  serialized_sequence_example, default_reward, moving_average_reward,
  policy_reward = inliner.collect_data(
      ir_path, tf_policy_path, default_reward, moving_average_reward)
  """

  def __init__(self, llvm_size_path: str, ir2perf_model_pickle_path: str, ir2vec_path: str, ir2vec_vocab_path: str, *args, **kwargs):
    super().__init__(*args, **kwargs)
    self._llvm_size_path = llvm_size_path
    with open(ir2perf_model_pickle_path, 'rb') as datafile:
        self.ir2perf = pickle.load(datafile)
    self._ir2vec_path = ir2vec_path
    self._ir2vec_vocab_path = ir2vec_vocab_path

  def compile_fn(
      self, command_line: corpus.FullyQualifiedCmdLine, tf_policy_path: str,
      reward_only: bool,
      workdir: str) -> Dict[str, Tuple[tf.train.SequenceExample, float]]:
    """Run inlining for the given IR file under the given policy.

    Args:
      command_line: the fully qualified command line.
      tf_policy_path: path to TF policy direcoty on local disk.
      reward_only: whether only return native size.

    Returns:
      A dict mapping from example identifier to tuple containing:
        sequence_example: A tf.SequenceExample proto describing compilation
        trace, None if reward_only == True.
        native_size: Native size of the final native code.

    Raises:
      subprocess.CalledProcessError: if process fails.
      compilation_runner.ProcessKilledError: (which it must pass through) on
      cancelled work.
      RuntimeError: if llvm-size produces unexpected output.
    """
    working_dir = tempfile.mkdtemp(dir=workdir)

    log_path = os.path.join(working_dir, 'log')
    output_native_path = os.path.join(working_dir, 'native')

    native_size = 0
    cmdline = []
    if self._launcher_path:
      cmdline.append(self._launcher_path)
    cmdline.extend([self._clang_path] + list(command_line) + [
        '-emit-llvm', '-mllvm', '-enable-ml-inliner=development', '-mllvm', '-training-log=' +
        log_path, '-o', output_native_path
    ])

    if tf_policy_path:
      cmdline.extend(
          ['-mllvm', '-ml-inliner-model-under-training=' + tf_policy_path])
    compilation_runner.start_cancellable_process(cmdline,
                                                 self._compilation_timeout,
                                                 self._cancellation_manager)

    compilation_runner.start_cancellable_process(['cp', output_native_path, '/home/student/native'], self._compilation_timeout, self._cancellation_manager)

    # get predicted runtime from IR2Perf
    output_native_path_embedding = os.path.join(working_dir, 'native-embedding')
    ir2vec_cmdline = [self._ir2vec_path, "--vocab=" + self._ir2vec_vocab_path, "--fa", "--level=f", "-o", output_native_path_embedding, output_native_path]
    compilation_runner.start_cancellable_process(ir2vec_cmdline,
                                                 self._compilation_timeout,
                                                 self._cancellation_manager)

    fvs = []
    # line format
    # <filename>.cpp<demangled func><TAB>vecdim0<TAB>...<TAB>vecdim299
    with open(output_native_path_embedding, 'r') as datafile:
        for line in datafile:
            fvs.append(list(map(float, line.split('\t')[2:-1])))

    reward = sum(self.ir2perf.predict(fvs))

    ## get reward as size
    #cmdline = [self._llvm_size_path, output_native_path]
    #output_bytes = compilation_runner.start_cancellable_process(
    #    cmdline,
    #    timeout=self._compilation_timeout,
    #    cancellation_manager=self._cancellation_manager,
    #    want_output=True)
    #if not output_bytes:
    #  print(f'Empty llvm-size output: {" ".join(cmdline)}')
    #  raise RuntimeError(f'Empty llvm-size output: {" ".join(cmdline)}')
    #output = output_bytes.decode('utf-8')
    #tmp = output.split('\n')
    #if len(tmp) != 3:
    #  print(f'Empty llvm-size output: {" ".join(cmdline)}')
    #  raise RuntimeError(f'Wrong llvm-size output {output}')
    #tmp = tmp[1].split('\t')
    #native_size = int(tmp[0])

    #if native_size == 0:
    #  return {}

    if reward_only:
      return {_DEFAULT_IDENTIFIER: (None, reward)}

    result = log_reader.read_log_as_sequence_examples(log_path)
    if len(result) != 1:
      return {}
    sequence_example = next(iter(result.values()))

    if not sequence_example.HasField('feature_lists'):
      return {}

    return {_DEFAULT_IDENTIFIER: (sequence_example, reward)}
