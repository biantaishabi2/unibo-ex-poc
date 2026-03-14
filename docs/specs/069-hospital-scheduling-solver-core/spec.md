# Specification: hospital_scheduling CP-SAT solver 集成层并行实现

## Overview
在 `hospital_scheduling/` 独立 app 骨架完成前，先并行实现 CP-SAT 求解的输入输出契约、Rust 集成层与夹具测试；业务编排与落库仍由后续 Elixir 层负责。

## Workflow Type
feature

## Task Scope

**In scope**：
- 定义 `input_snapshot -> output_snapshot` 的纯内存求解接口
- 固定 CP-SAT 建模所需的输入结构、输出结构、状态语义
- 在 Rust 中实现稳定的 solver integration boundary
- 为 `solve_from_blank` 与 `solve_from_previous_version` 两种入口预留统一接口
- 使用固定 fixture/内存 snapshot 编写契约测试
- 为后续 Elixir adapter 预留稳定的 JSON/CLI 或库接口
- 为 CP-SAT backend 接入保留最小可替换层

**Out of scope**：
- `SolverRun` / `ScheduleVersion` / `ShiftAssignment` / `ConstraintViolation` 正式落库
- Ash action / Repo transaction 接线
- GenServer 与真实 app supervision 接线
- 依赖最终 resource 名称、migration 字段、enum 类型的 glue 代码
- 把当前 worktree 中的启发式骨架当作最终求解方案
- 在 Rust 中重写 CP-SAT 引擎本身

## Success Criteria
- 能固定 CP-SAT 求解所需的 `input_snapshot` / `output_snapshot` 契约
- 能输出 coverage 摘要、error/warning explanation、`output_snapshot`
- 能区分 `solve_from_blank` 与 `solve_from_previous_version`
- Rust 侧契约测试不依赖数据库即可运行
- 接口形态固定，后续 Elixir 可用薄 adapter 接入

## Dev Environment

| 配置 | 值 |
|------|-----|
| 端口 | 4069 |
| Worktree | `/home/wangbo/document/unibo_ex_poc-feat-69-solver-core` |

启动命令：
```bash
cd /home/wangbo/document/unibo_ex_poc-feat-69-solver-core
```

## Requirements
- 遵循 `#69` 中约定的硬约束优先、软约束优化的分层语义
- 保证求解热路径只读内存 snapshot，不打数据库
- 以 `#68` 已冻结的 snapshot / violation / enum 契约为准
- Rust 代码注释使用中文
- 输出契约优先稳定，接线方式次之
- 当前 worktree 中的 Rust 代码只能作为 contract harness / adapter spike，不能被表述为最终求解算法

## Files to Modify
- `solver_rust/hospital_scheduling_solver/Cargo.toml`
- `solver_rust/hospital_scheduling_solver/src/*`
- `solver_rust/hospital_scheduling_solver/tests/*`
- 必要时新增 `solver_rust/hospital_scheduling_solver/README.md`
- `docs/specs/069-hospital-scheduling-solver-core/*`

## Files to Reference
- `docs/specs/069-hospital-scheduling-solver-core/spec.md`
- `docs/specs/069-hospital-scheduling-solver-core/plan.md`
- `#68` schema + snapshot 契约
- `#69` solver runtime issue 与评论
- `/home/wangbo/document/unibo_ex_poc/travel/mix.exs`

## QA Acceptance Criteria
- TC-SOLVER-01: 给定完整 snapshot，契约层能生成稳定的 `output_snapshot`
- TC-SOLVER-02: 无解 requirement 返回结构化 explanation，而不是无信息失败
- TC-SOLVER-03: 同一 seed + 同一 snapshot 结果可复现或差异可解释
- TC-SOLVER-04: `solve_from_previous_version` 能保留有效 seed assignment 语义

## Test Setup
- 使用纯内存 fixture，不依赖 Repo
- 先用最小数据集：8-12 个护士，7-14 天，3 类班次
- 允许先用 JSON fixture 驱动 CLI/库入口测试

## Test Cases
- `TC-SOLVER-01`: 空白解求解成功，返回 coverage / violations / score
- `TC-SOLVER-02`: 请假冲突或技能不足时返回 `error` explanation
- `TC-SOLVER-03`: 超时返回 best-so-far 或可解释 timeout 输出
- `TC-SOLVER-04`: 从上期版本 seed 进入后，锁定或 copied assignment 能被识别

## Step-by-step Validation
0. **冻结 solver 输入输出契约（待做）**
   - 做什么：把 `input_snapshot` 与 `output_snapshot` shape 固定为 Rust 入口契约
   - 验证：fixture JSON/内存 map 可被同一入口加载
1. **建立 CP-SAT 集成边界（待做）**
   - 做什么：把 Rust 侧边界明确为 adapter / contract harness，而非最终启发式
   - 验证：spec、plan、README 与 issue 口径一致
2. **补 explanation 与状态语义（待做）**
   - 做什么：固定 `feasible/infeasible/timeout/error/completed` 和 violation 输出
   - 验证：测试能看到稳定的 `error/warning` 两级输出
3. **补 seed 模式语义（待做）**
   - 做什么：固定 `solve_from_previous_version` 的输入输出语义
   - 验证：能保留有效 seed assignment 并输出修复结果
4. **预留 Elixir adapter 接口（待做）**
   - 做什么：固定 JSON 输入输出和返回码/状态语义
   - 验证：后续 Elixir 侧无需改动契约即可接线

## Notes
- 当前 worktree 只做 CP-SAT 集成层并行开发，不抢 `#68` 的持久化代码边界。
- 一旦 `#68` 正式代码落地，再由 Elixir 把 result 接到 `SolverRun` / `ScheduleVersion` / `ShiftAssignment` / `ConstraintViolation`。
- 当前 worktree 中已有的启发式代码只能视为 contract harness / fixture runner，不得继续扩写成最终 solver。
