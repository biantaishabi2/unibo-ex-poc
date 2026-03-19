#!/usr/bin/env bash
# Travel POC 多 input-dir 编译脚本
# - Core 模型从 unibo 主仓读取
# - POC 扩展模型从本地 models/ 读取
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
POC_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
UNIBO_ROOT="${UNIBO_ROOT:-/home/wangbo/document/unibo}"

cd "$UNIBO_ROOT"

cargo run -- compile-project \
  --target ash \
  --input-dir models \
  --input-dir "$POC_ROOT/models" \
  --output "$POC_ROOT/lib" \
  --module-prefix Travel \
  --repo Travel.Repo \
  --otp-app travel \
  --relation-mode warn \
  --seed Travel \
  --force
