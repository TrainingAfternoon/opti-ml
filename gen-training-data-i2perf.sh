#!/usr/bin/env bash

# generate a whole bunch of different in-lining configs and runtime benchmarks to train the ir2perf model with

source .env

MAX_LOOPS="${1:-37000}"
CORPUS="${_HOME}/ir2perf-corpus"

modules=(
    "x265" # https://openbenchmarking.org/test/pts/x265
    "npb" # https://openbenchmarking.org/test/pts/npb
    "encode-mp3" # https://openbenchmarking.org/test/pts/encode-mp3
    # "system/octave-benchmark" # https://openbenchmarking.org/test/system/octave-benchmark
    "cloverleaf" # https://openbenchmarking.org/test/pts/cloverleaf
    "encode-flac" # https://openbenchmarking.org/test/pts/encode-flac
    "glibc-bench" # https://openbenchmarking.org/test/pts/glibc-bench
    "c-ray" # https://openbenchmarking.org/test/pts/c-ray
)

compilers=(
    "$_HOME/compilers/base-clang/bin/clang"
    "$_HOME/compilers/random-clang/bin/clang"
)

heuristic_values=(
    "0" # inline nothing
    "80"
    "225" # default value
    "600"
    "1000" # in-line most everything
)
num_heuristic_values=${#heuristic_values[@]}

# get into the benchmark directory
cd $_HOME/cpp-perf-benchmarks

LOOPS=0
while [ $LOOPS -lt $MAX_LOOPS ]
do
    # choose compiler flags
    _CFLAGS="-O3 -fprofile-generate -fno-omit-frame-pointer -save-temps"

    compiler_idx=$(( ( RANDOM % 2 ) ))
    _CC=${compilers[$compiler_idx]}
    if [[  ! $_CC =~ .*random.* ]]
    then
        heuristic_idx=$(( ( RANDOM % $num_heuristic_values ) + 1))
        heuristic_value=${heuristic_values[$heuristic_idx]}

        _CFLAGS="${_CFLAGS} -mllvm -inline-threshold=${heuristic_value}"

        identifier=$heuristic_value
    else
        identifier="random"
    fi

    # set compiler flags
    #export $CC=$_CC
    #export CFLAGS=$_CFLAGS
    #export CXXFLAGS=$CFLAGS

    # set result file name
    timestamp=$(date +"%m-%d-%y-%H:%M")
    RESULTS_FOLDER="$CORPUS/${identifier}T${timestamp}"
    mkdir -p $RESULTS_FOLDER

    # compile test artifacts
    CC=$_HOME/compilers/base-clang/bin/clang CXX=$_HOME/compilers/base-clang/bin/clang++ \
        EXTRA_CFLAGS="-fprofile-generate -fno-omit-frame-pointer" \
        EXTRA_CXXFLAGS="-S -emit-llvm -fprofile-generate -fno-omit-frame-pointer" \
        make all

    # run benchmark
    make report

    # move artifacts to results file
    DESTDIR=$RESULTS_FOLDER make package

    # clean remaining artifacts
    make clean

    # increment loop counter
    LOOPS=$((LOOPS + 1))
done
