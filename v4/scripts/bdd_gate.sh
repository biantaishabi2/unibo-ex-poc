#!/usr/bin/env bash
set -euo pipefail

bddc runtime.caps.sync \
  --project-root . \
  --runtime-module UniboV4.BDD.Instructions.V1 \
  --out docs/bdd/_generated/runtime_caps_v1.exs

bddc check \
  --project-root . \
  --runtime-module UniboV4.BDD.Instructions.V1 \
  --runtime-caps-file docs/bdd/_generated/runtime_caps_v1.exs
