uuid_str = "88e814b9-5eee-4991-a8d6-8c7f3302d90f"
{:ok, uuid_bin} = Ecto.UUID.dump(uuid_str)

# Seed users with all required fields
try do
  result = Ecto.Adapters.SQL.query!(UniboV4.Repo,
    "SELECT column_name, is_nullable FROM information_schema.columns WHERE table_name = 'users' ORDER BY ordinal_position", [])
  required_cols = result.rows |> Enum.filter(fn [_, nullable] -> nullable == "NO" end) |> Enum.map(fn [name, _] -> name end)
  IO.puts("users required columns: #{inspect(required_cols)}")

  Ecto.Adapters.SQL.query!(UniboV4.Repo,
    "INSERT INTO users (id, name, email) VALUES ($1, $2, $3) ON CONFLICT DO NOTHING",
    [uuid_bin, "test_seed", "test@example.com"])
  IO.puts("Seeded users")
rescue
  e -> IO.puts("users: #{Exception.message(e) |> String.slice(0, 200)}")
end

# Seed crm_partners if exists
try do
  result = Ecto.Adapters.SQL.query!(UniboV4.Repo,
    "SELECT column_name, is_nullable FROM information_schema.columns WHERE table_name = 'crm_partners'", [])
  required = result.rows |> Enum.filter(fn [_, n] -> n == "NO" end) |> Enum.map(fn [c, _] -> c end)
  IO.puts("\ncrm_partners required: #{inspect(required)}")

  if "name" in required do
    Ecto.Adapters.SQL.query!(UniboV4.Repo,
      "INSERT INTO crm_partners (id, name) VALUES ($1, $2) ON CONFLICT DO NOTHING",
      [uuid_bin, "test_partner"])
  else
    Ecto.Adapters.SQL.query!(UniboV4.Repo,
      "INSERT INTO crm_partners (id) VALUES ($1) ON CONFLICT DO NOTHING",
      [uuid_bin])
  end
  IO.puts("Seeded crm_partners")
rescue
  e -> IO.puts("crm_partners: #{Exception.message(e) |> String.slice(0, 100)}")
end

# Seed purchasing_partners
try do
  Ecto.Adapters.SQL.query!(UniboV4.Repo,
    "INSERT INTO purchasing_partners (id, name) VALUES ($1, $2) ON CONFLICT DO NOTHING",
    [uuid_bin, "test_partner"])
  IO.puts("Seeded purchasing_partners")
rescue
  e -> IO.puts("purchasing_partners: #{Exception.message(e) |> String.slice(0, 100)}")
end

# Now verify the counts
check_tables = [
  "users", "crm_users", "purchasing_users", "sales_users",
  "maintenance_users", "maintenance_partners", "maintenance_companies"
]

IO.puts("\n--- Counts ---")
Enum.each(check_tables, fn t ->
  try do
    result = Ecto.Adapters.SQL.query!(UniboV4.Repo, "SELECT count(*) FROM #{t}", [])
    IO.puts("#{t}: #{inspect(hd(hd(result.rows)))}")
  rescue
    _ -> IO.puts("#{t}: error")
  end
end)
