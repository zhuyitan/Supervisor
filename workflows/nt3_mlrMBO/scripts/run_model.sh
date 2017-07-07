#!/bin/bash

set -eu

# Check for an optional timeout threshold in seconds. If the duration of the
# model run as executed below, takes longer that this threshhold
# then the run will be aborted. Note that the "timeout" command
# must be supported by executing OS.

# The timeout argument is optional. By default the "run_model" swift
# app fuction sends 3 arguments, and no timeout value is set. If there
# is a 4th (the TIMEOUT_ARG_INDEX) argument, we use that as the timeout value.

# !!! IF YOU CHANGE THE NUMBER OF ARGUMENTS PASSED TO THIS SCRIPT, YOU MUST
# CHANGE THE TIMEOUT_ARG_INDEX !!!
TIMEOUT_ARG_INDEX=9
TIMEOUT=""
if [[ $# ==  $TIMEOUT_ARG_INDEX ]]
then
	TIMEOUT=${!TIMEOUT_ARG_INDEX}
fi

TIMEOUT_CMD=""
if [ -n "$TIMEOUT" ]; then
  TIMEOUT_CMD="timeout $TIMEOUT"
fi

# string of parameters
parameter_string="$1"
echo $parameter_string

# Set emews_root to the root directory of the project (i.e. the directory
# that contains the scripts, swift, etc. directories and files)
emews_root=$2

# Each model run, runs in its own "instance" directory
# Set instance_directory to that and cd into it.
instance_directory=$3
cd $instance_directory

model_name=$4
framework=$5
exp_id=$6
run_id=$7
benchmark_timeout=$8

BENCHMARK_DIR=$emews_root/../../../Benchmarks/common:$emews_root/../../../Benchmarks/Pilot1/NT3:$emews_root/../../../Benchmarks/Pilot1/TC1
COMMON_DIR=$emews_root/../common/python
export PYTHONPATH="$PYTHONPATH:$BENCHMARK_DIR:$COMMON_DIR"

arg_array=("$emews_root/python/nt3_tc1_runner.py" "$parameter_string" "$instance_directory" "$model_name" "$framework" "$exp_id" "$run_id" "$benchmark_timeout")
MODEL_CMD="python ${arg_array[@]}"
# Turn bash error checking off. This is
# required to properly handle the model execution return value
# the optional timeout.
set +e
echo $MODEL_CMD
$TIMEOUT_CMD python "${arg_array[@]}"
# $? is the exit status of the most recently executed command (i.e the
# line above)
RES=$?
if [ "$RES" -ne 0 ]; then
	if [ "$RES" == 124 ]; then
    echo "---> Timeout error in $MODEL_CMD"
  else
	   echo "---> Error in $MODEL_CMD"
  fi
fi
