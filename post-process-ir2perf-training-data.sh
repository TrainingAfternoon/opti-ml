#!/usr/bin/env bash

source .env

profraw2yaml() {
    dest=$(echo $1 | cut -d'.' -f1 )".yaml"
    echo $dest
    $HOME/compilers/base-clang/bin/llvm-profdata show --all-functions --counts $1 > $dest
}

perf2perfdata() {
    dest=$(echo $1 | cut -d'.' -f1 )".perfdata"
    echo $dest
    # perf report -i $1 -n --stdio -g folded > $dest

    # get total cycles -- Runtime
    perf report -i $1 --stdio | grep "Event count" | cut -d' ' -f5 > $dest

    # get total number of samples in perf -- part of Tfunc
    perf report -i $1 --stdio --sort=comm,symbol -n | grep -E '^\s+[0-9]+.*\s\s.*\s\s.*' | awk '{print $3, $6}' | sort -rn | cut -d' ' -f1 | awk '{s+=$1} END {printf "%.0f\n", s}' >> $dest

    # get samples per function in perf -- part of Tfunc
    perf report -i $1 --no-demangle --stdio --sort=comm,symbol -n -U | grep -E '^\s+[0-9]+.*\s\s.*\s\s.*' | awk '{out = ""; for (i = 6; i <= NF; i++) {out = out " " $i}; print $3 "" out}' >> $dest
}

export -f profraw2yaml
export -f perf2perfdata

find $IR2PERF_CORPUS -name "*.profraw" -exec bash -c "profraw2yaml \"{}\"" \;
find $IR2PERF_CORPUS -name "*.perf" -exec bash -c "perf2perfdata \"{}\"" \;
