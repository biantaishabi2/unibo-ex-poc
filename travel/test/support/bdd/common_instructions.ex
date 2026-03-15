defmodule Travel.BDD.CommonInstructions do
  @moduledoc false

  @registry_module Travel.Generated.BddDomainRegistry
  @repo_module Travel.Repo
  @otp_app :travel
  @legacy_domain_aliases %{
    "COMMON" => "OFBIZ_COMMON",
    "PARTY" => "OFBIZ_PARTY",
    "PRODUCT" => "OFBIZ_PRODUCT",
    "ORDER" => "OFBIZ_ORDER",
    "SHIPMENT" => "OFBIZ_SHIPMENT",
    "ACCOUNTING" => "OFBIZ_ACCOUNTING"
  }

  def capabilities, do: UniboBddRuntime.CommonInstructions.capabilities()

  def run!(ctx, :given, :given_seed_context, %{id: id, module: module} = args, meta) do
    ensure_legacy_flat_source!(id, module)
    canonical_args = Map.put(args, :module, canonicalize_module(module))

    UniboBddRuntime.CommonInstructions.run!(ctx, :given, :given_seed_context, canonical_args, meta, %{
      registry: @registry_module,
      repo: @repo_module,
      otp_app: @otp_app
    })
  end

  def run!(ctx, kind, name, args, meta) do
    UniboBddRuntime.CommonInstructions.run!(ctx, kind, name, args, meta, %{
      registry: @registry_module,
      repo: @repo_module,
      otp_app: @otp_app
    })
  end

  # 兼容 travel 历史上把 source yaml 平铺在 priv/bdd/sources 根目录的布局。
  defp ensure_legacy_flat_source!(id, module) do
    {domain, entity_prefixes} = parse_module(module)
    candidate_filenames = candidate_source_filenames(id, entity_prefixes)
    build_sources_root = Path.join(:code.priv_dir(@otp_app), "bdd/sources")
    project_sources_root = Path.expand("../../../priv/bdd/sources", __DIR__)
    domain_dir = Map.fetch!(@registry_module.module_dirs(), domain)
    nested_path = Path.join([build_sources_root, domain_dir, hd(candidate_filenames)])

    source_path =
      candidate_filenames
      |> Enum.flat_map(fn filename ->
        [
          Path.join([build_sources_root, domain_dir, filename]),
          Path.join(build_sources_root, filename),
          Path.join([project_sources_root, domain_dir, filename]),
          Path.join(project_sources_root, filename)
        ]
      end)
      |> Enum.find(&File.exists?/1)

    cond do
      File.exists?(nested_path) ->
        :ok

      is_binary(source_path) ->
        File.mkdir_p!(Path.dirname(nested_path))

        case File.cp(source_path, nested_path) do
          :ok -> :ok
          {:error, :eexist} -> :ok
          {:error, reason} -> raise "copy legacy BDD source failed: #{inspect(reason)}"
        end

      true ->
        :ok
    end
  end

  defp parse_module(module) do
    original_module = module
    module = canonicalize_module(module)

    match =
      @registry_module.module_dirs()
      |> Map.keys()
      |> Enum.filter(&String.starts_with?(module, &1))
      |> Enum.sort_by(&String.length/1, :desc)
      |> List.first()

    case match do
      nil ->
        case String.split(module, "_", parts: 2) do
          [domain, entity] ->
            {Map.get(@legacy_domain_aliases, domain, domain), [legacy_module_prefix(original_module), entity_prefix(entity)]}

          [domain] ->
            {Map.get(@legacy_domain_aliases, domain, domain), [legacy_module_prefix(original_module)]}
        end

      domain ->
        entity =
          module
          |> String.replace_prefix(domain <> "_", "")
          |> entity_prefix()

        {domain, Enum.uniq([legacy_module_prefix(original_module), entity])}
    end
  end

  defp canonicalize_module(module) when is_binary(module) do
    case String.split(module, "_", parts: 2) do
      [domain, rest] ->
        canonical_domain = Map.get(@legacy_domain_aliases, domain, domain)

        if canonical_domain == domain do
          module
        else
          canonical_domain <> "_" <> rest
        end

      [domain] ->
        Map.get(@legacy_domain_aliases, domain, domain)
    end
  end

  defp candidate_source_filenames(id, prefixes) when is_list(prefixes) do
    [id <> ".yaml"] ++
      Enum.map(prefixes, fn prefix ->
        String.replace_prefix(id, prefix, "") <> ".yaml"
      end)
    |> Enum.uniq()
  end

  defp entity_prefix(""), do: ""

  defp entity_prefix(entity) do
    entity
    |> String.downcase()
    |> Kernel.<>("_")
  end

  defp legacy_module_prefix(module) do
    module
    |> String.downcase()
    |> Kernel.<>("_")
  end
end
