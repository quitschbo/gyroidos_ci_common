#!/usr/bin/env bash

# Jenkins executes this script before it builds the gyroidos image (i.e. pre-yocto).
# If this script exits with a non-zero code, the whole pipeline fails.
# Right now it is used to execute the unit tests in libcommon
# However, it can be extended and used for any pre-build-time task (fuzzing, other tests, etc).

set -e
set -o pipefail

REPO_DIR="$(cd "$1" >/dev/null 2>&1 && pwd)"

# Piggyback on the compiler's static analysis;
# Build every subproject with enabled aggressive warnings;
# Check if the compiler catches any errors
dirs=(common control converter daemon scd)
for d in ${dirs[*]}; do
    cd "${REPO_DIR}/common"
    make clean

    cd "${REPO_DIR}/${d}"
    make clean
    AGGRESSIVE_WARNINGS=y make
    make clean
done

# Execute the unit tests for libcommon without sanitizers
# TODO: Execute the unit tests for libcommon with enabled sanitizers
# TODO: write more libcommon tests
cd "${REPO_DIR}/common"
make clean
SANITIZERS=n make test
make clean

#TODO: execute here other tests or other pre-yocto jobs
