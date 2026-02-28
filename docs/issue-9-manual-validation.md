# Issue #9 手工验证记录（最小闭环）

## 执行时间

- 2026-02-28

## 场景 A：编译产物接入可编译

- 命令 1：`scripts/verify_codegen_poc.sh`
- 预期：自动链路通过，生成 Ash 产物
- 实际：
  - `import` 成功（112 实体）
  - `compile` 成功（113 个 `.ex` 文件，含 1 个 Domain）
  - smoke check 通过
- 结论：通过

- 命令 2：`mix compile`
- 预期：PoC 工程可编译
- 实际：编译成功（`Generated unibo_ex_poc app`）
- 结论：通过

## 场景 B/C/D：GraphQL 规则手工验证

- 命令：`mix run scripts/manual_verify_issue9.exs`
- 产物：`docs/issue-9-manual-validation.json`

### 规则 1：风险供应商拦截

- 正例输入：低风险供应商创建订单
- 预期：创建成功，返回订单 ID
- 实际：`createOrderV3.result.id` 返回非空，`errors` 为空
- 结论：通过

- 反例输入：高风险供应商创建订单
- 预期：创建失败，提示风险等级过高
- 实际：`createOrderV3.result = null`，错误为“供应商风险等级过高，禁止下单”
- 结论：通过

### 规则 2：状态流转约束

- 正例输入：`created -> submit`
- 预期：状态变为 `submitted`
- 实际：`submitOrderV3.result.status = submitted`
- 结论：通过

- 反例输入：`created -> approve`（未提交直接审批）
- 预期：审批失败
- 实际：`approveOrderV3.result = null`，错误为“只有已提交订单可以审批”
- 结论：通过

### 规则 3：大额单高级审批

- 正例输入：`admin` 执行 `seniorApproveOrderV3`
- 预期：高级审批成功，状态 `approved`
- 实际：`seniorApproveOrderV3.result.status = approved`
- 结论：通过

- 反例输入：`buyer` 对大额单执行普通 `approveOrderV3`
- 预期：普通审批失败
- 实际：`approveOrderV3.result = null`，错误为“订单金额达到分级阈值，需走高级审批”
- 结论：通过

## 验收结论

- `mix compile` 通过
- 3 条核心规则均完成“正例 + 反例”手工验证
- 每个场景均有输入/预期/实际/结论记录
- 最小验证模板已沉淀（脚本 + JSON 结果 + 本文档）
