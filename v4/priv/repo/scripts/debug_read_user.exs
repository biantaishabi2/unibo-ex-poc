alias UniboBddRuntime.DataFactory

# 检查 User 表里有没有数据
resources = [
  UniboV4.CRM.User,
  UniboV4.Purchasing.User,
  UniboV4.Maintenance.User,
]

Enum.each(resources, fn resource ->
  short = resource |> Module.split() |> Enum.take(-2) |> Enum.join(".")
  domain = Ash.Resource.Info.domain(resource)

  if domain do
    try do
      case Ash.read(resource, domain: domain, page: [limit: 1]) do
        {:ok, %{results: results}} ->
          IO.puts("#{short}: #{length(results)} records (paged)")
        {:ok, results} when is_list(results) ->
          IO.puts("#{short}: #{length(results)} records")
        other ->
          IO.puts("#{short}: unexpected result #{inspect(other)}")
      end
    rescue
      e -> IO.puts("#{short}: error - #{Exception.message(e) |> String.slice(0, 100)}")
    end
  else
    IO.puts("#{short}: no domain")
  end
end)

# 检查是否有任何 users 表中的记录
IO.puts("\n--- Direct DB check ---")
try do
  result = Ecto.Adapters.SQL.query!(UniboV4.Repo, "SELECT count(*) FROM iam_users", [])
  IO.puts("iam_users count: #{inspect(result.rows)}")
rescue
  e -> IO.puts("iam_users: #{Exception.message(e) |> String.slice(0, 100)}")
end

try do
  result = Ecto.Adapters.SQL.query!(UniboV4.Repo, "SELECT count(*) FROM crm_users", [])
  IO.puts("crm_users count: #{inspect(result.rows)}")
rescue
  e -> IO.puts("crm_users: #{Exception.message(e) |> String.slice(0, 100)}")
end

# 尝试直接查 iam.users 或 public.users
try do
  result = Ecto.Adapters.SQL.query!(UniboV4.Repo,
    "SELECT table_name FROM information_schema.tables WHERE table_name LIKE '%user%' AND table_schema = 'public' LIMIT 10", [])
  IO.puts("User tables: #{inspect(result.rows)}")
rescue
  e -> IO.puts("table query: #{Exception.message(e) |> String.slice(0, 100)}")
end
