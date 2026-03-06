uuid_str = Ash.UUID.generate()
{:ok, uuid_bin} = Ecto.UUID.dump(uuid_str)

# Seed all user tables with one common ID
tables = [
  "crm_users", "purchasing_users", "sales_users", "accounting_users",
  "approvals_users", "documents_users", "spreadsheet_users", "users"
]

Enum.each(tables, fn t ->
  try do
    Ecto.Adapters.SQL.query!(UniboV4.Repo, "INSERT INTO #{t} (id) VALUES ($1) ON CONFLICT DO NOTHING", [uuid_bin])
    IO.puts("Seeded #{t}: #{uuid_str}")
  rescue
    e -> IO.puts("#{t}: #{Exception.message(e) |> String.slice(0, 100)}")
  end
end)

# Tables that need name
name_tables = [
  "maintenance_users", "maintenance_partners", "maintenance_companies",
  "maintenance_stock_locations"
]

Enum.each(name_tables, fn t ->
  try do
    Ecto.Adapters.SQL.query!(UniboV4.Repo, "INSERT INTO #{t} (id, name) VALUES ($1, $2) ON CONFLICT DO NOTHING", [uuid_bin, "test_seed"])
    IO.puts("Seeded #{t}: #{uuid_str}")
  rescue
    e -> IO.puts("#{t}: #{Exception.message(e) |> String.slice(0, 100)}")
  end
end)

# Also seed common entity tables that actors may reference
more_tables = [
  {"gamification_res_users", false},
  {"sign_users", false},
  {"expenses_users", false},
  {"rental_users", false},
  {"communication_users", false},
  {"e_learning_users", false},
  {"membership_res_users", false},
  {"membership_res_partners", false},
  {"live_chat_users", false},
  {"knowledge_users", false},
  {"lunch_users", false},
  {"marketing_users", false},
  {"ecommerce_users", false},
  {"project_users", false},
  {"blog_users", false},
  {"forum_users", false},
  {"pos_users", false},
  {"studio_users", false},
  {"helpdesk_users", false},
  {"subscriptions_users", false},
  {"plm_users", false},
  {"quality_users", false},
  {"data_recycle_res_users", false},
]

Enum.each(more_tables, fn {t, needs_name} ->
  try do
    if needs_name do
      Ecto.Adapters.SQL.query!(UniboV4.Repo, "INSERT INTO #{t} (id, name) VALUES ($1, $2) ON CONFLICT DO NOTHING", [uuid_bin, "test_seed"])
    else
      Ecto.Adapters.SQL.query!(UniboV4.Repo, "INSERT INTO #{t} (id) VALUES ($1) ON CONFLICT DO NOTHING", [uuid_bin])
    end
    IO.puts("Seeded #{t}")
  rescue
    e -> IO.puts("#{t}: #{Exception.message(e) |> String.slice(0, 60)}")
  end
end)

IO.puts("\nDone seeding. UUID: #{uuid_str}")
