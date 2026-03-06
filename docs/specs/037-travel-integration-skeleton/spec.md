# Specification: Travel Independent Stack In POC

## Overview
在 POC 根应用中独立落一套 `travel` stack，不依赖 `v4`，直接把主仓 canonical travel model 编译接入，并在外层补 `host contract / host config / supplier adapter`。

## Workflow Type
feature

## Task Scope

**In scope**：
- 明确 `v4` 不参与本次 travel POC
- 把主仓 `models/travel/travel.ubo.yaml` 编译到 POC 根应用
- 在 POC 根应用中建立独立 `travel` 目录与模块边界
- 定义宿主 `shop -> travel sidecar` 的 `CallerContext` 能力契约
- 定义 `travel -> host` 的 `EligibilityOrQuote` / `PaymentExecution` 能力契约
- 定义 `travel -> supplier` 的 hotel adapter skeleton
- 为 hotel 场景补最小可验证流程与测试桩

**Out of scope**：
- `v4` ERP/Odoo 验证线
- supplier 真实生产接口全量接入
- 宿主后台完整 UI 页面
- flight / vacation 全量业务闭环
- canonical domain model 再次改形

## Success Criteria
- POC 根应用中存在独立 `travel` stack，且不依赖 `v4`
- 主仓 canonical travel model 已编译进入 POC
- `CallerContext` 结构固定，可被 travel sidecar 消费
- `EligibilityOrQuote` 能表达 travel 开关、积分支付、混合支付、可用性结果
- hotel supplier adapter 与 canonical model 隔离
- hotel 最小闭环可通过测试验证

## Requirements
- `shop` 是宿主，`travel` 是 sidecar
- 宿主配置和支付/积分规则留在宿主
- `travel` 不直接读取宿主配置模型
- supplier 差异只能放 adapter 层
- `v4` 与本次 travel POC 解耦
- 先不预设 HTTP / RPC，只定义能力契约

## Files to Modify
- `docs/specs/037-travel-integration-skeleton/spec.md`
- `lib/unibo_ex_poc/travel/**`
- `lib/unibo_ex_poc/travel_host/**`
- `lib/unibo_ex_poc/travel_supplier/**`
- `test/unibo_ex_poc/travel/**`

## Files to Reference
- `../unibo/models/travel/travel.ubo.yaml`
- `README.md`

## Dev Environment

| 配置 | 值 |
|------|-----|
| 端口 | 4005 |
| Worktree | `../unibo_ex_poc-feat-37` |
| Branch | `feat/37-travel-integration-skeleton` |

启动命令：
```bash
cd ../unibo_ex_poc-feat-37 && PORT=4005 mix phx.server
```

## QA Acceptance Criteria
- TC-TRAVEL-STACK-01: 主仓 travel model 能编译进 POC 根应用
- TC-TRAVEL-HOST-01: 宿主上下文能归一化为 `CallerContext`
- TC-TRAVEL-HOST-02: 宿主配置变更会影响 `EligibilityOrQuote`
- TC-TRAVEL-SUPPLIER-01: hotel canonical payload 能映射到 supplier adapter request
- TC-TRAVEL-FLOW-01: hotel quote -> payment -> booking skeleton 能跑通

## Notes
- Parent issue: `#36`
- Implementation issue: `#37`
- `v4` 是 ERP/Odoo 验证线，本阶段不参与 travel POC

## Next
- 先生成独立 travel stack
- 再补 host contract / config / adapter
- 最后补最小测试与 issue 同步
