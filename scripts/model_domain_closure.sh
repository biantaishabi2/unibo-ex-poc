#!/usr/bin/env bash
set -euo pipefail

# POC 入口脚本：转调主仓 unibo 的最小依赖闭包计算脚本。
# 默认路径：../unibo/scripts/model_domain_closure.sh
# 可通过 UNIBO_ROOT 覆盖主仓路径。

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
UNIBO_ROOT="${UNIBO_ROOT:-$ROOT_DIR/../unibo}"
TARGET_SCRIPT="$UNIBO_ROOT/scripts/model_domain_closure.sh"

if [[ ! -x "$TARGET_SCRIPT" ]]; then
  echo "错误: 找不到可执行脚本: $TARGET_SCRIPT" >&2
  echo "请确认 unibo 主仓路径，或设置 UNIBO_ROOT 后重试。" >&2
  exit 1
fi

exec "$TARGET_SCRIPT" "$@"
