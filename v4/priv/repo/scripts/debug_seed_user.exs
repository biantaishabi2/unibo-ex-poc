# 检查 users 表
try do
  result = Ecto.Adapters.SQL.query!(UniboV4.Repo, "SELECT count(*) FROM users", [])
  IO.puts("users count: #{inspect(result.rows)}")
rescue
  e -> IO.puts("users: #{Exception.message(e) |> String.slice(0, 100)}")
end

# 检查 crm_users 表结构
try do
  result = Ecto.Adapters.SQL.query!(UniboV4.Repo,
    "SELECT column_name, data_type FROM information_schema.columns WHERE table_name = 'crm_users' ORDER BY ordinal_position LIMIT 10", [])
  IO.puts("\ncrm_users columns:")
  Enum.each(result.rows, fn [name, type] ->
    IO.puts("  #{name}: #{type}")
  end)
rescue
  e -> IO.puts("crm_users columns: #{Exception.message(e) |> String.slice(0, 100)}")
end

# 能不能直接往 crm_users 插一条记录？
IO.puts("\n--- Trying to seed a user ---")
try do
  id = Ash.UUID.generate()
  Ecto.Adapters.SQL.query!(UniboV4.Repo,
    "INSERT INTO crm_users (id, inserted_at, updated_at) VALUES ($1, NOW(), NOW()) ON CONFLICT DO NOTHING RETURNING id",
    [id])
  IO.puts("Seeded crm_users with id=#{id}")

  # 验证
  result = Ecto.Adapters.SQL.query!(UniboV4.Repo, "SELECT count(*) FROM crm_users", [])
  IO.puts("crm_users count after seed: #{inspect(result.rows)}")
rescue
  e -> IO.puts("Seed failed: #{Exception.message(e) |> String.slice(0, 200)}")
end
