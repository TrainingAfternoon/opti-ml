#!/usr/bin/env bash

source .env

CC_BASE=$1
echo "Using CC=${CC_BASE}"

RESULTS_DIR="$_HOME/benchmarking-results"
echo "Using RESULTS_DIR=${RESULTS_DIR}"
mkdir -p $RESULTS_DIR

# run cpp-perf-benchmarks
echo "Running cpp-perf-benchmarks"
cd $_HOME/cpp-perf-benchmarks-3

make clean
CC=$CC_BASE/bin/clang CXX=$CC_BASE/bin/clang++ \
    EXTRA_CFLAGS="-fprofile-generate -fno-omit-frame-pointer" \
    EXTRA_CXXFLAGS="-mllvm -enable-ml-inliner=release -fprofile-generate -fno-omit-frame-pointer" \
    make all

REPORT_FILE="$RESULTS_DIR/mlgo-2-cpp-perf-benchmarks.log"
NUMA_CPU=12
for i in {1..5}
do
    #REPORT_FILE="$RESULTS_DIR/mlgo-2-cpp-perf-benchmarks.log" \
    #NUMA_CPU=12 \
    #    make report-thin
   echo "##STARTING Version 1.0" >> $REPORT_FILE
   date >> $REPORT_FILE
   
   echo "machine" >> $REPORT_FILE
   { time -p numactl --physcpubind=$NUMA_CPU timeout 4m ./machine ; } 2>> $REPORT_FILE
   sudo /sbin/sysctl vm.drop_caches=1
   
   echo "functionobjects" >> $REPORT_FILE
   { time -p numactl --physcpubind=$NUMA_CPU timeout 4m ./functionobjects ; } 2>> $REPORT_FILE
   sudo /sbin/sysctl vm.drop_caches=1
   
   echo "loop removal" >> $REPORT_FILE
   { time numactl --physcpubind=$NUMA_CPU timeout 4m ./loop_removal ; } 2>> $REPORT_FILE
   sudo /sbin/sysctl vm.drop_caches=1
   
   echo "locales" >> $REPORT_FILE
   { time numactl --physcpubind=$NUMA_CPU timeout 4m ./locales ; } 2>> $REPORT_FILE
   sudo /sbin/sysctl vm.drop_caches=1
   
   echo "rotate bits" >> $REPORT_FILE
   { time numactl --physcpubind=$NUMA_CPU timeout 4m ./rotate_bits ; } 2>> $REPORT_FILE
   sudo /sbin/sysctl vm.drop_caches=1
   
   echo "scalar replacement structs" >> $REPORT_FILE
   { time numactl --physcpubind=$NUMA_CPU timeout 4m ./scalar_replacement_structs ; } 2>> $REPORT_FILE
   sudo /sbin/sysctl vm.drop_caches=1
   
   date >> $REPORT_FILE
   echo "##END Version 1.0" >> $REPORT_FILE
done

# run cBench
echo "Running cBench benchmarks"
cd $_HOME/cBench-2

export ZCC="${CC_BASE}/bin/clang"
export LDCC="${CC_BASE}/bin/clang"
export NUMA_CPU=12
bash all_compile llvm

for i in {1..5}
do
    export BENCH_RESULTS_FILE=$RESULTS_DIR/mlgo-2-cBench-benchmarks.log
    bash all_run__1_dataset
done

echo "Done!"
