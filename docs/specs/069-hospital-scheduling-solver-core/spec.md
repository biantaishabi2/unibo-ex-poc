# Specification: hospital_scheduling Rust solver core 并行实现

## Overview
在 `hospital_scheduling/` 独立 app 骨架完成前，先并行实现不依赖数据库和 Phoenix 的 Rust solver core，并由后续 Elixir 层负责编排与落库。

## Workflow Type
feature

## Task Scope

**In scope**：
- 定义 `input_snapshot -> output_snapshot` 的纯内存求解接口
- 在 Rust 中实现 solver 五阶段骨架：`load_snapshot`、`seed_initial_solution`、`repair_hard_constraints`、`improve_soft_score`、`emit_result`
- 实现基础约束检查、评分和 explanation 生成
- 支持 `solve_from_blank` 与 `solve_from_previous_version` 两种入口
- 使用固定 fixture/内存 snapshot 编写 solver 单测
- 为后续 Elixir adapter 预留稳定的 JSON/CLI 或库接口

**Out of scope**：
- `SolverRun` / `ScheduleVersion` / `ShiftAssignment` / `ConstraintViolation` 正式落库
- Ash action / Repo transaction 接线
- GenServer 与真实 app supervision 接线
- 依赖最终 resource 名称、migration 字段、enum 类型的 glue 代码
- 直接实现 CP-SAT 引擎本身

## Success Criteria
- 能基于固定 `input_snapshot` 生成稳定的内存态求解结果
- 能输出 coverage 摘要、error/warning explanation、`output_snapshot`
- 能区分 `solve_from_blank` 与 `solve_from_previous_version`
- Rust 求解核心测试不依赖数据库即可运行
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
- 遵循 `#69` 中约定的五阶段 solver 生命周期
- 保证求解热路径只读内存 snapshot，不打数据库
- 以 `#68` 已冻结的 snapshot / violation / enum 契约为准
- Rust 代码注释使用中文
- 输出契约优先稳定，接线方式次之

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
- TC-SOLVER-01: 给定完整 snapshot，生成 working result 和 coverage summary
- TC-SOLVER-02: 无解 requirement 返回结构化 explanation，而不是无信息失败
- TC-SOLVER-03: 同一 seed + 同一 snapshot 结果可复现或差异可解释
- TC-SOLVER-04: `solve_from_previous_version` 能保留有效 seed assignment

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
1. **实现五阶段骨架（待做）**
   - 做什么：在 Rust 中实现五阶段 pipeline 和结果 struct
   - 验证：最小 fixture 能跑通全阶段
2. **补约束与 explanation（待做）**
   - 做什么：补 hard repair、soft score、violation 生成
   - 验证：测试能看到 `error/warning` 两级输出
3. **补 seed 模式（待做）**
   - 做什么：实现 `solve_from_previous_version`
   - 验证：能保留有效 seed assignment 并输出修复结果
4. **预留 Elixir adapter 接口（待做）**
   - 做什么：固定 JSON 输入输出和返回码/状态语义
   - 验证：后续 Elixir 侧无需修改 Rust 内核即可接线

## Notes
- 当前 worktree 只做 Rust solver core 并行开发，不抢 `#68` 的持久化代码边界。
- 一旦 `#68` 正式代码落地，再由 Elixir 把内存态 result 接到 `SolverRun` / `ScheduleVersion` / `ShiftAssignment` / `ConstraintViolation`。
- 当前目标不是在 Rust 中重写 CP-SAT，而是先把求解主循环移出 Elixir，为后续更强后端留接口。
