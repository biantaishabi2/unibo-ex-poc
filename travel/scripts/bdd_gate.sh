#!/usr/bin/env bash
set -euo pipefail

# 中文注释：默认跳过 annotations 全量扫描，避免在 travel 闭包场景下触发大规模编译耗时。
# 如需完整门禁，可在执行前设置：
#   SKIP_ANNOTATIONS_CHECK=false SKIP_BDD_TEST=false bash scripts/bdd_gate.sh
SKIP_ANNOTATIONS_CHECK="${SKIP_ANNOTATIONS_CHECK:-true}"
SKIP_BDD_TEST="${SKIP_BDD_TEST:-true}"
BDD_IN="${BDD_IN:-docs/bdd/travel/scenarios}"
FAIL_ON_WARN="${FAIL_ON_WARN:-false}"

bddc runtime.caps.sync \
  --project-root . \
  --runtime-module UniboExPoc.BDD.Instructions.V1 \
  --out docs/bdd/_generated/runtime_caps_v1.exs

cmd=(
  bddc check
  --project-root .
  --in "${BDD_IN}"
  --runtime-module UniboExPoc.BDD.Instructions.V1
  --runtime-caps-file docs/bdd/_generated/runtime_caps_v1.exs
  --fail-on-warn "${FAIL_ON_WARN}"
)

if [[ "${SKIP_ANNOTATIONS_CHECK}" == "true" ]]; then
  cmd+=(--skip-annotations-check)
fi

if [[ "${SKIP_BDD_TEST}" == "true" ]]; then
  cmd+=(--skip-bdd-test)
fi

"${cmd[@]}"
