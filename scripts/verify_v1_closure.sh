#!/usr/bin/env bash
set -euo pipefail

# V1 收尾验收：自动生成链路 + 后端回归
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "[1/2] 验证 OFBiz XML -> UniBO IR -> Ash DSL"
"$ROOT_DIR/scripts/verify_codegen_poc.sh"

echo "[2/2] 验证 PoC 后端测试"
(
  cd "$ROOT_DIR"
  mix test
)

echo "V1 收尾验收通过"
