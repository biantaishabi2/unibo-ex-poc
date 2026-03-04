alias UniboV4.Generated.BddDomainRegistry
domains = BddDomainRegistry.domain_map()
missing = Enum.reduce(domains, [], fn {_domain_name, domain_mod}, acc ->
  try do
    resources = Ash.Domain.Info.resources(domain_mod)
    Enum.reduce(resources, acc, fn resource, acc2 ->
      data_layer = Ash.Resource.Info.data_layer(resource)
      if data_layer == AshPostgres.DataLayer do
        table = AshPostgres.DataLayer.Info.table(resource)
        if table do
          result = Ecto.Adapters.SQL.query(UniboV4.Repo, "SELECT 1 FROM information_schema.tables WHERE table_schema = $1 AND table_name = $2", ["public", table])
          case result do
            {:ok, %{num_rows: 0}} -> [{table, resource} | acc2]
            _ -> acc2
          end
        else
          acc2
        end
      else
        acc2
      end
    end)
  rescue
    _ -> acc
  end
end)
IO.puts("Missing tables: #{length(missing)}")
missing |> Enum.sort() |> Enum.each(fn {table, resource} ->
  IO.puts("  #{table} -> #{inspect(resource)}")
end)
