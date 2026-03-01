# 为各域的 User 表插入测试用户
alias UniboV4.Repo

user_id = Ecto.UUID.generate()

# 查找各域的 User 表
tables = ["sales_users", "accounting_users", "purchasing_users"]

for table <- tables do
  # 检查表是否存在
  case Repo.query("SELECT column_name FROM information_schema.columns WHERE table_name = '#{table}' ORDER BY ordinal_position") do
    {:ok, %{rows: cols}} when cols != [] ->
      col_names = Enum.map(cols, fn [c] -> c end)
      IO.puts("Table #{table} columns: #{inspect(col_names)}")

      # 检查是否已有用户
      case Repo.query("SELECT id FROM #{table} LIMIT 1") do
        {:ok, %{rows: [[existing_id]]}} ->
          IO.puts("  Already has user: #{existing_id}")

        _ ->
          # 构建 INSERT — 基础字段
          fields = ["id"]
          values = ["'#{user_id}'::uuid"]

          if "name" in col_names do
            fields = fields ++ ["name"]
            values = values ++ ["'Dev Test User'"]
          end

          if "email" in col_names do
            fields = fields ++ ["email"]
            values = values ++ ["'dev@test.com'"]
          end

          if "inserted_at" in col_names do
            fields = fields ++ ["inserted_at"]
            values = values ++ ["NOW()"]
          end

          if "updated_at" in col_names do
            fields = fields ++ ["updated_at"]
            values = values ++ ["NOW()"]
          end

          sql = "INSERT INTO #{table} (#{Enum.join(fields, ", ")}) VALUES (#{Enum.join(values, ", ")})"
          IO.puts("  SQL: #{sql}")

          case Repo.query(sql) do
            {:ok, _} -> IO.puts("  Inserted user #{user_id}")
            {:error, err} -> IO.puts("  Error: #{inspect(err)}")
          end
      end

    _ ->
      IO.puts("Table #{table} not found")
  end
end

IO.puts("\nUser ID for all domains: #{user_id}")
