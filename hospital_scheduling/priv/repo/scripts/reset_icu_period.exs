# 重置 ICU period 为 draft，清理旧 solver 数据
alias HospitalScheduling.Repo

id = Ecto.UUID.dump!("62041f94-0d41-41aa-acfe-b054e45dba9e")

Repo.transaction(fn ->
  # 解除 period 的所有 FK 引用
  Repo.query!("UPDATE scheduling_periods SET current_version_id = NULL, last_solver_run_id = NULL, source_version_id = NULL, published_version_id = NULL WHERE id = $1", [id])
  Repo.query!("UPDATE scheduling_schedule_versions SET based_on_run_id = NULL, source_version_id = NULL WHERE period_id = $1", [id])

  # 清 paper_trail versions 表（查所有可能的 _versions 表）
  for tbl <- ["scheduling_shift_assignments", "scheduling_constraint_violations", "scheduling_solver_runs", "scheduling_schedule_versions", "scheduling_periods"] do
    vtbl = tbl <> "_versions"
    try do
      if tbl == "scheduling_periods" do
        Repo.query!("DELETE FROM #{vtbl} WHERE version_source_id = $1", [id])
      else
        Repo.query!("DELETE FROM #{vtbl} WHERE version_source_id IN (SELECT id FROM #{tbl} WHERE period_id = $1)", [id])
      end
    rescue
      _ -> :ok
    end
  end

  # 清业务表
  Repo.query!("DELETE FROM scheduling_shift_assignments WHERE period_id = $1", [id])
  Repo.query!("DELETE FROM scheduling_constraint_violations WHERE period_id = $1", [id])
  Repo.query!("DELETE FROM scheduling_schedule_versions WHERE period_id = $1", [id])
  Repo.query!("DELETE FROM scheduling_solver_runs WHERE period_id = $1", [id])

  # 重置状态
  Repo.query!("UPDATE scheduling_periods SET state = 'draft' WHERE id = $1", [id])
end)

r = Repo.query!("SELECT state FROM scheduling_periods WHERE id = $1", [id])
IO.puts("ICU period state: #{hd(hd(r.rows))}")
