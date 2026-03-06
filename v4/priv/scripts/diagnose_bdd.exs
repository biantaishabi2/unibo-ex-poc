alias UniboV4.BDD.{AshIntrospector, DataFactory}

Ecto.Adapters.SQL.Sandbox.mode(UniboV4.Repo, :manual)
_pid = Ecto.Adapters.SQL.Sandbox.start_owner!(UniboV4.Repo, shared: false)

domains = AshIntrospector.domains()

results = Enum.flat_map(domains, fn domain ->
  try do
    resources = Ash.Domain.Info.resources(domain)
    Enum.map(resources, fn resource ->
      name = resource |> Module.split() |> Enum.join(".")
      actions = Ash.Resource.Info.actions(resource)
      create_action = Enum.find(actions, fn a -> a.type == :create and a.primary? end) || Enum.find(actions, fn a -> a.type == :create end)

      if create_action do
        try do
          _record = DataFactory.create_record!(resource, create_action.name)
          {:ok, name, create_action.name}
        rescue
          e -> {:error, name, create_action.name, Exception.message(e)}
        end
      else
        {:skip, name, :no_create_action}
      end
    end)
  rescue
    _ -> []
  end
end)

IO.puts("=== SUCCESS ===")
results |> Enum.filter(fn r -> elem(r, 0) == :ok end) |> Enum.each(fn {:ok, name, action} ->
  IO.puts("  ✓ #{name} (#{action})")
end)

IO.puts("\n=== FAILED ===")
results |> Enum.filter(fn r -> elem(r, 0) == :error end) |> Enum.each(fn {:error, name, action, msg} ->
  short = msg |> String.slice(0, 300)
  IO.puts("  ✗ #{name} (#{action}): #{short}")
end)

IO.puts("\n=== NO CREATE ACTION ===")
results |> Enum.filter(fn r -> elem(r, 0) == :skip end) |> Enum.each(fn {:skip, name, _} ->
  IO.puts("  - #{name}")
end)

ok = Enum.count(results, fn r -> elem(r, 0) == :ok end)
fail = Enum.count(results, fn r -> elem(r, 0) == :error end)
skip = Enum.count(results, fn r -> elem(r, 0) == :skip end)
IO.puts("\nTotal: #{ok} ok, #{fail} failed, #{skip} skipped")
