# Plan: hospital_scheduling CP-SAT 集成层

## Overview
把 `#69` 收敛为一个可并行开发的 CP-SAT 集成层，短期先产出稳定的输入输出契约、Rust adapter 边界与夹具测试，后续再由 Elixir adapter 接入业务系统。

## Phase Plan

### Phase 0: 契约冻结
- 明确 `input_snapshot` / `output_snapshot` Rust 数据结构
- 明确 run mode：
  - `solve_from_blank`
  - `solve_from_previous_version`
- 明确 solver status 与 error/warning explanation shape

交付：
- Rust struct 草案
- fixture JSON
- 序列化/反序列化测试

### Phase 1: 工程骨架
- 新建 `solver_rust/hospital_scheduling_solver/`
- 初始化 `Cargo.toml`
- 建立模块结构：
  - `snapshot`
  - `model`
  - `adapter`
  - `rules`
  - `score`
  - `explanation`
  - `output`

交付：
- `cargo test` 可跑
- 空骨架带基础测试

### Phase 2: adapter / harness
- 把当前 Rust crate 明确成 contract harness
- 允许用最小启发式仅做 fixture/状态/解释验证
- 不再把它表述为最终求解器

交付：
- 一条最小 fixture 跑通完整输入输出
- 返回 coverage summary / score / violations

### Phase 3: CP-SAT backend 接入方案
- 明确 CP-SAT backend 载体
- 明确 Rust 如何调用 backend
- 明确输入输出转换层

交付：
- backend 接入设计
- adapter 边界文档

### Phase 4: previous version seed
- 接受 source version assignments
- 固定 copied/locked assignment 的语义
- 与 CP-SAT 输入模型对齐

交付：
- `solve_from_previous_version` 契约测试
- copied/seed 来源解释

### Phase 5: Elixir adapter 预留
- 固定 JSON CLI 契约或薄库接口
- 明确 exit code / status 映射
- 预留 README 给后续 `hospital_scheduling` app 接入

交付：
- adapter contract 文档
- demo fixture 输入输出样例

## Proposed File Layout

```text
solver_rust/hospital_scheduling_solver/
├── Cargo.toml
├── src/
│   ├── lib.rs
│   ├── snapshot.rs
│   ├── model.rs
│   ├── solver.rs              # 当前仅作 contract harness，不代表最终算法
│   ├── output.rs
│   ├── explanation.rs
│   ├── rules/
│   │   ├── mod.rs
│   │   ├── hard.rs
│   │   └── soft.rs
│   └── score.rs
└── tests/
    ├── blank_mode.rs
    ├── previous_version.rs
    ├── hard_constraints.rs
    └── explanations.rs
```

## Acceptance
- `cargo test` 可在 worktree 中独立运行
- harness 可用 fixture 跑出稳定 result
- 可区分 `feasible` / `infeasible` / `timeout` / `error`
- explanation 输出稳定
- 不依赖数据库和 Phoenix
- issue / spec / worktree 对 “CP-SAT 是目标后端，当前 Rust 代码不是最终启发式” 的口径一致

## Notes
- 本计划故意不提前实现 Ash/Repo/GenServer 接线。
- 当前最重要的纠偏是：不要再把 worktree 里的启发式代码当作最终求解方案。
