result = UniboV4.Repo.query!("SELECT tablename FROM pg_tables WHERE schemaname = 'public' ORDER BY tablename")
IO.puts("=== Tables in DB (#{length(result.rows)}) ===")
Enum.each(result.rows, fn [t] -> IO.puts(t) end)
