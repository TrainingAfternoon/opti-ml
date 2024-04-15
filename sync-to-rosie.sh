#!/usr/bin/env bash

source .env
rsync -ravtz $IR2PERF_CORPUS keysers@dh-mgmt2.hpc.msoe.edu:~/capstone/
