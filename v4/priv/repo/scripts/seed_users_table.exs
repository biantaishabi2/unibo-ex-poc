uuid_str = "88e814b9-5eee-4991-a8d6-8c7f3302d90f"
{:ok, uuid_bin} = Ecto.UUID.dump(uuid_str)

try do
  Ecto.Adapters.SQL.query!(UniboV4.Repo,
    "INSERT INTO users (id, name) VALUES ($1, $2) ON CONFLICT DO NOTHING",
    [uuid_bin, "test_seed"])
  IO.puts("Seeded users table")
rescue
  e -> IO.puts("Failed: #{Exception.message(e) |> String.slice(0, 200)}")
end

# Also seed partner tables
partner_tables = ["crm_partners", "purchasing_partners", "lunch_partners", "communication_res_partners"]
Enum.each(partner_tables, fn t ->
  try do
    result = Ecto.Adapters.SQL.query!(UniboV4.Repo,
      "SELECT column_name FROM information_schema.columns WHERE table_name = $1", [t])
    cols = Enum.map(result.rows, fn [c] -> c end)

    if "name" in cols do
      Ecto.Adapters.SQL.query!(UniboV4.Repo,
        "INSERT INTO #{t} (id, name) VALUES ($1, $2) ON CONFLICT DO NOTHING",
        [uuid_bin, "test_seed"])
    else
      Ecto.Adapters.SQL.query!(UniboV4.Repo,
        "INSERT INTO #{t} (id) VALUES ($1) ON CONFLICT DO NOTHING",
        [uuid_bin])
    end
    IO.puts("Seeded #{t}")
  rescue
    e -> IO.puts("#{t}: #{Exception.message(e) |> String.slice(0, 80)}")
  end
end)

# Seed io_t_users (might have integer PK)
try do
  Ecto.Adapters.SQL.query!(UniboV4.Repo,
    "INSERT INTO io_t_users (id) VALUES ($1) ON CONFLICT DO NOTHING",
    [1])
  IO.puts("Seeded io_t_users")
rescue
  e -> IO.puts("io_t_users: #{Exception.message(e) |> String.slice(0, 80)}")
end
