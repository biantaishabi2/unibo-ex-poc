# 护士排班系统 V1 完整演示脚本
#
# 运行方式：
#   mix run priv/repo/seeds.exs         # 先加载种子数据
#   mix run priv/repo/scripts/demo.exs  # 再运行演示
#
# 10 步完整流程：
# 1. 加载排班周期
# 2. 查看需求矩阵
# 3. 启动自动排班（状态 → generating）
# 4. 执行 solver 求解
# 5. 查看求解结果（版本、assignment、violation）
# 6. 锁定一个班次
# 7. 二次求解（带锁定）
# 8. 对比两个版本
# 9. 发布前检查
# 10. 发布排班

alias HospitalScheduling.{Scheduling, Repo}
alias HospitalScheduling.Solver.{Runner, SnapshotAssembler, AggregateChecker}
require Ash.Query
require Logger

defmodule Demo do
  def separator(step, title) do
    IO.puts("\n#{"=" |> String.duplicate(60)}")
    IO.puts("  Step #{step}: #{title}")
    IO.puts("#{"=" |> String.duplicate(60)}\n")
  end

  def print_assignments(assignments, limit \\ 10) do
    shown = Enum.take(assignments, limit)
    Enum.each(shown, fn a ->
      IO.puts("    员工 #{a.employee_id |> String.slice(0..7)}... | " <>
              "#{a.starts_at} → #{a.ends_at} | " <>
              "来源: #{a.source} | 锁定: #{a.is_locked}")
    end)
    if length(assignments) > limit do
      IO.puts("    ... 还有 #{length(assignments) - limit} 条")
    end
  end

  def print_violations(violations) do
    if violations == [] do
      IO.puts("    （无违规）")
    else
      Enum.each(violations, fn v ->
        IO.puts("    [#{v.severity}] #{v.rule_code}: #{v.message}")
      end)
    end
  end
end

# ── Step 1: 加载排班周期 ────────────────────────────────

Demo.separator(1, "加载排班周期")

{:ok, [period | _]} =
  Scheduling.SchedulingPeriod
  |> Ash.Query.sort(inserted_at: :desc)
  |> Ash.Query.limit(1)
  |> Ash.read(authorize?: false)

IO.puts("  周期: #{period.title}")
IO.puts("  日期: #{period.start_date} ~ #{period.end_date}")
IO.puts("  状态: #{period.state}")

# ── Step 2: 查看需求矩阵 ────────────────────────────────

Demo.separator(2, "查看需求矩阵")

{:ok, requirements} =
  Scheduling.CoverageRequirement
  |> Ash.Query.filter(period_id == ^period.id)
  |> Ash.Query.sort(requirement_date: :asc)
  |> Ash.Query.load([:shift_type])
  |> Ash.read(authorize?: false)

# 按日期分组
by_date = Enum.group_by(requirements, & &1.requirement_date)
Enum.each(Enum.sort(Map.keys(by_date)), fn date ->
  reqs = by_date[date]
  shifts = Enum.map(reqs, fn r ->
    "#{r.shift_type.name}(#{r.min_headcount}人)"
  end)
  IO.puts("  #{date}: #{Enum.join(shifts, " | ")}")
end)
IO.puts("\n  总需求: #{length(requirements)} 条")

# ── Step 3: 启动自动排班 ────────────────────────────────

Demo.separator(3, "启动自动排班（draft → generating）")

{:ok, period} = Ash.update(period, %{}, action: :start_generating, authorize?: false)
IO.puts("  状态变更: draft → #{period.state}")

# ── Step 4: 执行 solver 求解 ────────────────────────────

Demo.separator(4, "执行 solver 求解（MockAdapter）")

{:ok, result1} = Runner.run(period.id, seed: 42, timeout_ms: 15_000)

IO.puts("  版本号: v#{result1.version.version_no}")
IO.puts("  来源: #{result1.version.origin_type}")
IO.puts("  分配数: #{length(result1.assignments)}")
IO.puts("  违规数: #{length(result1.violations)}")

# ── Step 5: 查看求解结果 ────────────────────────────────

Demo.separator(5, "查看求解结果")

IO.puts("  排班分配（前 10 条）:")
Demo.print_assignments(result1.assignments)

IO.puts("\n  约束违规:")
Demo.print_violations(result1.violations)

# ── Step 6: 锁定一个班次 ────────────────────────────────

Demo.separator(6, "锁定第一个班次")

first_assignment = hd(result1.assignments)
{:ok, locked} = Ash.update(first_assignment, %{}, action: :lock, authorize?: false)

IO.puts("  锁定: 员工 #{locked.employee_id |> String.slice(0..7)}...")
IO.puts("  时段: #{locked.starts_at} → #{locked.ends_at}")
IO.puts("  is_locked: #{locked.is_locked}")

# ── Step 7: 二次求解（带锁定） ──────────────────────────

Demo.separator(7, "二次求解（带锁定 assignment）")

locked_data = [%{
  employee_id: locked.employee_id,
  requirement_id: locked.requirement_id,
  starts_at: locked.starts_at,
  ends_at: locked.ends_at
}]

{:ok, result2} = Runner.run(period.id, seed: 99, locked_assignments: locked_data)

IO.puts("  版本号: v#{result2.version.version_no}")
IO.puts("  分配数: #{length(result2.assignments)}")
IO.puts("  违规数: #{length(result2.violations)}")

# ── Step 8: 对比两个版本 ────────────────────────────────

Demo.separator(8, "对比两个版本")

v1_emps = MapSet.new(result1.assignments, fn a -> {a.employee_id, a.starts_at} end)
v2_emps = MapSet.new(result2.assignments, fn a -> {a.employee_id, a.starts_at} end)

same = MapSet.intersection(v1_emps, v2_emps) |> MapSet.size()
only_v1 = MapSet.difference(v1_emps, v2_emps) |> MapSet.size()
only_v2 = MapSet.difference(v2_emps, v1_emps) |> MapSet.size()

IO.puts("  v1 分配数: #{MapSet.size(v1_emps)}")
IO.puts("  v2 分配数: #{MapSet.size(v2_emps)}")
IO.puts("  相同: #{same} | 仅 v1: #{only_v1} | 仅 v2: #{only_v2}")

# ── Step 9: 发布前检查 ──────────────────────────────────

Demo.separator(9, "发布前检查（AggregateChecker）")

{:ok, check} = Runner.pre_publish_check(result2.version.id)

IO.puts("  可发布: #{check.publishable}")
IO.puts("  错误数: #{length(check.errors)}")
IO.puts("  警告数: #{length(check.warnings)}")

if check.errors != [] do
  IO.puts("\n  错误详情:")
  Enum.each(check.errors, fn e ->
    IO.puts("    [#{e[:severity] || e.severity}] #{e[:message] || e.message}")
  end)
end

# ── Step 10: 发布排班 ───────────────────────────────────

Demo.separator(10, "发布排班")

# 重新加载 period（状态可能已被 Runner 更新）
{:ok, period} = Ash.get(Scheduling.SchedulingPeriod, period.id, authorize?: false)

if check.publishable do
  # 确保状态为 generated 或 adjusted
  period =
    case period.state do
      :generated -> period
      :adjusted -> period
      state ->
        IO.puts("  当前状态 #{state}，跳过发布")
        period
    end

  if period.state in [:generated, :adjusted] do
    {:ok, published} = Ash.update(period, %{}, action: :publish, authorize?: false)
    IO.puts("  ✅ 排班已发布！状态: #{published.state}")

    # 发布版本
    {:ok, pub_version} = Ash.update(result2.version, %{},
      action: :publish_version, authorize?: false)
    IO.puts("  ✅ 版本 v#{pub_version.version_no} 已发布，状态: #{pub_version.status}")
  end
else
  IO.puts("  ⚠️ 存在 #{length(check.errors)} 个错误，无法发布")
  IO.puts("  需要先解决以上错误才能发布排班")
end

IO.puts("""

#{"=" |> String.duplicate(60)}
  演示完成！
#{"=" |> String.duplicate(60)}

V1 已验证链路：
  ✓ 种子数据加载
  ✓ 需求矩阵查看
  ✓ 自动排班求解（MockAdapter）
  ✓ 结果查看（版本/分配/违规）
  ✓ 班次锁定 + 二次求解
  ✓ 版本对比
  ✓ 发布前检查
  ✓ 排班发布

V1 未覆盖（留给后续迭代）：
  ○ 真实 CP-SAT solver（当前用 Mock）
  ○ 前端页面联调
  ○ 多科室并行排班
  ○ 跨周期克隆
""")
