#!/usr/bin/env bash

# generate a whole bunch of different in-lining configs and runtime benchmarks to train the ir2perf model with

source .env

MAX_LOOPS="${1:-37000}"
#CORPUS="${_HOME}/ir2perf-corpus"
CORPUS=$IR2PERF_CORPUS

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
#    "$_HOME/compilers/random-clang/bin/clang" # TODO: why does this sometimes hang?
)

heuristic_values=(
    "0" # inline nothing
    "25"
    "50"
    "75"
    "100"
    "125"
    "150"
    "175"
    "200"
    "225"
    "250"
    "275"
    "300"
    "325"
    "350"
    "375"
    "400"
    "425"
    "450"
    "475"
    "500"
    "525"
    "550"
    "575"
    "600"
    "625"
    "650"
    "675"
    "700"
    "725"
    "750"
    "775"
    "800"
    "825"
    "850"
    "875"
    "900"
    "925"
    "950"
    "975"
    "1000" # inline basically everything
)
num_heuristic_values=${#heuristic_values[@]}

# get into the benchmark directory
cd $_HOME/cpp-perf-benchmarks
make clean

LOOPS=0
while [ $LOOPS -lt $MAX_LOOPS ]
do
    # choose compiler flags
    _CFLAGS="-lm -fprofile-generate -fno-omit-frame-pointer"

    #compiler_idx=$(( ( RANDOM % 2 ) ))
    compiler_idx=0
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
    CC=$_CC CXX=$_CC \
        EXTRA_CFLAGS=$_CFLAGS \
        EXTRA_CXXFLAGS=$_CFLAGS \
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
