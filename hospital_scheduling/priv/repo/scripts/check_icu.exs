import Ecto.Query
alias HospitalScheduling.{Repo, Scheduling}
pid = "62041f94-0d41-41aa-acfe-b054e45dba9e"

period = Ash.get!(Scheduling.SchedulingPeriod, pid, authorize?: false)
IO.puts("Period: state=#{period.state}")

# 用 SQL 直接查，避免 Ash 过滤问题
bin_id = Ecto.UUID.dump!(pid)
r = Repo.query!("SELECT status, score, hard_violation_count, warning_count FROM scheduling_solver_runs WHERE period_id = $1 ORDER BY inserted_at DESC LIMIT 1", [bin_id])
if length(r.rows) > 0 do
  [[state, score, hard, warn]] = r.rows
  IO.puts("SolverRun: state=#{state} score=#{inspect(score)} hard_violations=#{hard} warnings=#{warn}")
else
  IO.puts("SolverRun: none found")
end

r2 = Repo.query!("SELECT count(*) FROM scheduling_shift_assignments WHERE period_id = $1", [bin_id])
IO.puts("Assignments: #{hd(hd(r2.rows))}")

r3 = Repo.query!("SELECT count(*) FROM scheduling_constraint_violations WHERE period_id = $1", [bin_id])
IO.puts("Violations: #{hd(hd(r3.rows))}")
