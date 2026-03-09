# !usr/bin/env bash
set -e

# test bench name
TOP=

# simulation snap-shot name
SIM=sim_${TOP}

MODE=${1:-all}   # default = all

# working directory
WORK_DIR=../
cd $WORK_DIR

# cmd.exe used to run cmd in Window through WSL
if [[ "$MODE" == "all" ]]; then
    echo "1 ▶ Compile"
    cmd.exe /c xvlog -sv -f scripts/filelist.f

    echo "2 ▶ Elaborate"
    cmd.exe /c xelab work.$TOP -s $SIM --debug typical
fi

echo "3 ▶ Simulate"
cmd.exe /c xsim $SIM -runall

echo "✅Simulation Completed🔚"