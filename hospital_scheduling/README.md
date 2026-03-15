# Hospital Scheduling — 护士排班系统 V1

基于 Ash Framework 的护士排班系统，支持约束求解、版本管理、发布流程。

## 环境要求

- Elixir 1.15+
- Erlang/OTP 26+
- PostgreSQL 14+

## 快速启动

```bash
# 1. 安装依赖
mix deps.get

# 2. 创建数据库
mix ecto.create

# 3. 运行迁移
mix ecto.migrate

# 4. 加载种子数据
mix run priv/repo/seeds.exs

# 5. 启动开发服务器
mix phx.server
```

## 运行测试

```bash
# 全部测试
mix test

# 集成测试（V1 主链路）
mix test test/integration/

# Solver 单元测试
mix test test/hospital_scheduling/solver/

# BDD 自动生成测试
mix test test/bdd_generated/
```

## 演示脚本

```bash
# 先加载种子数据（如果还没有）
mix run priv/repo/seeds.exs

# 运行 10 步完整演示
mix run priv/repo/scripts/demo.exs
```

演示覆盖的完整流程：

1. 加载排班周期
2. 查看需求矩阵（7 天 × 3 班次）
3. 启动自动排班（draft → generating）
4. 执行 solver 求解（MockAdapter 贪心算法）
5. 查看求解结果（版本、分配、违规）
6. 锁定一个班次
7. 二次求解（带锁定约束）
8. 对比两个版本差异
9. 发布前检查（AggregateChecker）
10. 发布排班

## 架构概览

### 领域模型

| 资源 | 说明 |
|------|------|
| Department | 科室（跨域引用） |
| Employee | 护士（跨域引用） |
| MedicalStaffProfile | 护士能力档案（带班资格、成熟度、工作限制） |
| ShiftType | 班次类型（白班/小夜/大夜） |
| SchedulingPeriod | 排班周期（状态机：draft → generating → generated → published） |
| CoverageRequirement | 覆盖需求（每日每班需要几人） |
| ShiftAssignment | 班次分配（具体到人、时间） |
| ScheduleVersion | 排班版本（solver 每次生成一个版本） |
| SolverRun | 求解记录（含输入/输出快照） |
| SchedulingConstraint | 约束规则（硬约束/软约束） |
| ShiftPreference | 护士偏好（班次偏好、请假、夜班上限） |
| ConstraintViolation | 约束违规记录 |

### Solver 运行时

```
Runner.run(period_id)
  ├── SnapshotAssembler.assemble()  # 冻结输入快照
  ├── SolverRun.create()            # 创建求解记录
  ├── Adapter.solve(snapshot)        # 调用求解器
  │   ├── MockAdapter               # 测试用贪心算法
  │   └── SolverBridge → Rust       # 生产用 CP-SAT（未集成）
  ├── ResultWriter.write_result()    # 落库 version/assignment/violation
  └── AggregateChecker.check()       # 发布前校验
```

### 页面路由

| 路径 | 页面 | 说明 |
|------|------|------|
| /scheduling/ | 排班周期列表 | CRUD + 状态管理 |
| /scheduling/requirement_matrix | 需求矩阵 | 按日期×班次填写需求 |
| /scheduling/solver_result | 求解结果 | KPI + 违规列表 |
| /scheduling/calendar_adjustment | 日历调班 | 手动调整 + 锁定 |
| /scheduling/publish_preview | 发布预览 | 差异对比 + 发布 |

## V1 范围

### 已完成

- 12 个 Ash 资源定义（含状态机、审计、级联归档）
- Solver 运行时（MockAdapter 贪心算法）
- 完整 input/output snapshot 合约
- ScheduleVersion 版本管理
- AggregateChecker 发布前校验
- 10 个前端页面（Stitch DSL 编译）
- 集成测试（4 个验收场景）
- GraphQL API

### 未覆盖（后续迭代）

- 真实 CP-SAT solver 集成（当前用 MockAdapter）
- 前端页面与后端 API 联调（SchedulingLive 事件接线）
- 路由收口到资源化路径
- 多科室并行排班
- 跨周期克隆
