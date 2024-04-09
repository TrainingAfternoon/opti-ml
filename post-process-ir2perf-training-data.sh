#!/usr/bin/env bash

source .env

profraw2yaml() {
    dest=$(echo $1 | cut -d'.' -f1 )".yaml"
    echo $dest
    $HOME/compilers/base-clang/bin/llvm-profdata show --all-functions --counts $1 > $dest
}

perf2csv() {
    dest=$(echo $1 | cut -d'.' -f1 )".csv"
    echo $dest
    perf report -i $1 -n --stdio -g folded > $dest
}

export -f profraw2yaml
export -f perf2csv

find $IR2PERF_CORPUS -name "*.profraw" -exec bash -c "profraw2yaml \"{}\"" \;
find $IR2PERF_CORPUS -name "*.perf" -exec bash -c "perf2csv \"{}\"" \;
