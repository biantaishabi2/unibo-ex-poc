#!/usr/bin/env bash
# Hospital Scheduling POC 多 input-dir 编译脚本
# - Core 模型从 unibo 主仓读取（hr 等跨域引用）
# - POC 行业 vertical 模型从本地 models/ 读取（覆盖 Core scheduling）
#
# 因为 POC 的 scheduling.ubo.yaml 是完整行业 vertical（替代而非扩展 Core），
# 需要排除 Core 的 scheduling/ 子目录，避免合并后产生重复域声明。
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
POC_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
UNIBO_ROOT="${UNIBO_ROOT:-/home/wangbo/document/unibo}"

# 创建临时目录，将 Core models 中除 scheduling/ 外的子目录软链接进去
CORE_FILTERED=$(mktemp -d)
trap "rm -rf '$CORE_FILTERED'" EXIT

for d in "$UNIBO_ROOT/models"/*/; do
  dir_name=$(basename "$d")
  if [ "$dir_name" = "scheduling" ]; then
    continue  # POC 自带完整 scheduling vertical，跳过 Core 的
  fi
  ln -s "$d" "$CORE_FILTERED/$dir_name"
done

cd "$UNIBO_ROOT"

cargo run -- compile-project \
  --target ash \
  --input-dir "$CORE_FILTERED" \
  --input-dir "$POC_ROOT/models" \
  --output "$POC_ROOT/lib" \
  --module-prefix HospitalScheduling \
  --repo HospitalScheduling.Repo \
  --otp-app hospital_scheduling \
  --relation-mode warn \
  --seed Scheduling \
  --force
