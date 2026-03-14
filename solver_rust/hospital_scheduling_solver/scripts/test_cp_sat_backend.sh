#!/usr/bin/env bash
set -euo pipefail

# 允许调用方覆盖 OR-Tools 安装位置；默认指向当前机器已经验证通过的目录。
: "${ORTOOLS_PREFIX:=/home/wangbo/.local/opt/ortools/v9.15.6755}"

export ORTOOLS_PREFIX
export LD_LIBRARY_PATH="${ORTOOLS_PREFIX}/lib${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}"
export LIBRARY_PATH="${ORTOOLS_PREFIX}/lib${LIBRARY_PATH:+:${LIBRARY_PATH}}"
export CXXFLAGS="${CXXFLAGS:+${CXXFLAGS} }-DOR_PROTO_DLL="
export RUSTFLAGS="${RUSTFLAGS:+${RUSTFLAGS} }-L native=${ORTOOLS_PREFIX}/lib -Clink-arg=-lprotobuf"

cargo test --features cp_sat_backend "$@"
