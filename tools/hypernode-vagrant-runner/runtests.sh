#!/usr/bin/env bash
set -e

if [ ! -d venv ]; then
    virtualenv venv
fi

venv/bin/pip install distribute --upgrade --quiet  # Update distribute
venv/bin/pip install -r requirements/development.txt --exists-action w --quiet

while getopts "1" opt; do
    case $opt in
        1) RUN_ONCE=1;;
    esac
done

shift $((OPTIND - 1))

if [ -e "/proc/cpuinfo" ]; then
    numprocs=$(cat /proc/cpuinfo  | grep processor | wc -l | cut -d ' ' -f 1)
elif [ "x$(uname)" = "xDarwin" ]; then
    numprocs=$(sysctl -n hw.ncpu)
else
    numprocs=1
fi

# Don't write .pyc files
export PYTHONDONTWRITEBYTECODE=1  
# Remove existing .pyc files
find . -type f -name *.pyc -delete

test_cmd="
    echo 'Running hypernode_vagrant_runner unit tests';
    venv/bin/nosetests --processes=$numprocs;
    echo 'Checking PEP8';
    venv/bin/autopep8 -r --diff hypernode_vagrant_runner;
"

if [ -z $RUN_ONCE ]; then
    LC_NUMERIC="en_US.UTF-8" watch -c -n 0.1 -- "$test_cmd"
else
    sh -ec "$test_cmd"
fi
