#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
PROJECT_DIR=$(cd -- "$SCRIPT_DIR/.." && pwd)

export ORTOOLS_PREFIX="${ORTOOLS_PREFIX:-/home/wangbo/.local/opt/ortools/v9.15.6755}"
export LD_LIBRARY_PATH="$ORTOOLS_PREFIX/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
export LIBRARY_PATH="$ORTOOLS_PREFIX/lib${LIBRARY_PATH:+:$LIBRARY_PATH}"
export CXXFLAGS="${CXXFLAGS:--DOR_PROTO_DLL=}"
export RUSTFLAGS="${RUSTFLAGS:--L native=$ORTOOLS_PREFIX/lib -Clink-arg=-lprotobuf}"

cd "$PROJECT_DIR"

if [[ $# -gt 0 ]]; then
  exec cargo run --quiet --features cp_sat_backend --bin solve_snapshot -- < "$1"
else
  exec cargo run --quiet --features cp_sat_backend --bin solve_snapshot -- "$@"
fi
