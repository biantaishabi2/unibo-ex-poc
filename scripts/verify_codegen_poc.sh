#!/usr/bin/env bash
set -euo pipefail

# 验证 POC 自动链路：OFBiz XML -> UniBO IR -> Ash DSL
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
UNIBO_ROOT="${UNIBO_ROOT:-$ROOT_DIR/../unibo}"
OFBIZ_ROOT="${OFBIZ_ROOT:-$ROOT_DIR/../ofbiz}"
ORDER_XML="${ORDER_XML:-$OFBIZ_ROOT/applications/datamodel/entitydef/order-entitymodel.xml}"

if [[ ! -f "$ORDER_XML" ]]; then
  echo "错误: 找不到 OFBiz XML: $ORDER_XML" >&2
  exit 1
fi

if [[ ! -f "$UNIBO_ROOT/Cargo.toml" ]]; then
  echo "错误: 找不到 unibo 仓库: $UNIBO_ROOT" >&2
  exit 1
fi

TMP_DIR="$(mktemp -d /tmp/unibo_poc_codegen.XXXXXX)"
trap 'rm -rf "$TMP_DIR"' EXIT

IR_YAML="$TMP_DIR/order_ir.yaml"
ASH_OUT="$TMP_DIR/ash_out"

echo "[1/3] import OFBiz XML -> IR"
(
  cd "$UNIBO_ROOT"
  cargo run --quiet -- import \
    --from ofbiz \
    --input "$ORDER_XML" \
    --output "$IR_YAML" \
    --domain Purchasing
)

echo "[2/3] compile IR -> Ash DSL"
(
  cd "$UNIBO_ROOT"
  cargo run --quiet -- compile \
    --target ash \
    --input "$IR_YAML" \
    --output "$ASH_OUT" \
    --module-prefix UniboExPoc.Purchasing.Generated \
    --repo UniboExPoc.Repo
)

echo "[3/3] smoke checks"
FILE_COUNT="$(find "$ASH_OUT" -maxdepth 1 -type f -name '*.ex' | wc -l | tr -d ' ')"
if [[ "$FILE_COUNT" -lt 50 ]]; then
  echo "错误: 生成模块数量异常，当前只有 $FILE_COUNT 个" >&2
  exit 1
fi

# 编译器可能调整 domain 文件名，这里按 "use Ash.Domain + 模块前缀" 判定
DOMAIN_FILE="$(rg -l "use Ash.Domain" "$ASH_OUT"/*.ex | head -n 1 || true)"
if [[ -z "${DOMAIN_FILE:-}" ]]; then
  echo "错误: 未生成 Ash.Domain 模块" >&2
  exit 1
fi

if ! grep -q "defmodule UniboExPoc.Purchasing.Generated" "$DOMAIN_FILE"; then
  echo "错误: Domain 模块前缀不符合预期: $DOMAIN_FILE" >&2
  exit 1
fi

# 历史回归检查：应为 `source_attribute :foo`，不能是 `source_attribute: :foo`
if rg -n "source_attribute:" "$ASH_OUT"/*.ex >/dev/null 2>&1; then
  echo "错误: 发现非法 DSL 语法 source_attribute: :..." >&2
  exit 1
fi

echo "验证通过: 自动链路可用"
echo "生成模块数: $FILE_COUNT"
echo "临时输出目录: $ASH_OUT"
