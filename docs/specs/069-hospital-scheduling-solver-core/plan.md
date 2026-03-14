# Plan: hospital_scheduling Rust solver core

## Overview
把 `#69` 收敛为一个可并行开发的 Rust 求解核心，短期先产出稳定的输入输出契约和启发式求解骨架，后续再由 Elixir adapter 接入业务系统。

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
  - `solver`
  - `rules`
  - `score`
  - `explanation`
  - `output`

交付：
- `cargo test` 可跑
- 空骨架带基础测试

### Phase 2: 五阶段 pipeline
- `load_snapshot`
- `seed_initial_solution`
- `repair_hard_constraints`
- `improve_soft_score`
- `emit_result`

交付：
- 一条最小 fixture 跑通全阶段
- 返回 coverage summary / score / violations

### Phase 3: 规则与 explanation
- 补硬约束检查：
  - 请假冲突
  - 夜班后休息
  - 连续工作天数
  - lead coverage
  - skill requirement
- 补软约束评分：
  - 夜班公平
  - 周末公平
  - preference
  - 连续夜班限制
  - 班次连续性

交付：
- error/warning explanation 稳定输出
- 规则级单测

### Phase 4: previous version seed
- 接受 source version assignments
- 过滤无效 seed assignment
- 保留 copied/locked assignment
- 进入 repair + improve

交付：
- `solve_from_previous_version` 单测
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
│   ├── solver.rs
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
- solver 可用 fixture 跑出 result
- 可区分 `feasible` / `infeasible` / `timeout` / `error`
- explanation 输出稳定
- 不依赖数据库和 Phoenix

## Notes
- 本计划故意不提前实现 Ash/Repo/GenServer 接线。
- 如果后续决定接更强后端（如 OR-Tools/CP-SAT），优先在 Rust 侧演进，不回灌到 Elixir 业务层。
