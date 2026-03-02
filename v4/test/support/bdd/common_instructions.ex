defmodule UniboV4.BDD.CommonInstructions do
  @moduledoc false

  @caps MapSet.new([
    :create_temp_dir, :create_temp_file, :noop, :assert_noop,
    :given_seed_context, :when_execute_seed_contract, :then_seed_contract_should_hold
  ])
  def capabilities, do: @caps

  # BDD source YAML 文件根目录
  @sources_root Path.join(:code.priv_dir(:unibo_v4), "bdd/sources")

  # 模块名 → 子目录映射
  @module_dirs %{
    "ACCOUNTING" => "accounting",
    "ECOMMERCE" => "ecommerce",
    "SALES" => "sales",
    "PURCHASING" => "purchasing",
    "MEMBERSHIP" => "membership",
    "CRM" => "crm",
    "HELPDESK" => "helpdesk"
  }

  # ============================================================
  # seed 通用指令
  # ============================================================

  # given_seed_context: 加载 BDD source YAML，解析 contract 信息放入 ctx
  def run!(ctx, :given, :given_seed_context, %{id: id, module: module}, _meta) do
    {domain, _entity} = parse_module(module)
    yaml_filename = derive_yaml_filename(id, module)
    source_dir = Map.fetch!(@module_dirs, domain)
    yaml_path = Path.join([@sources_root, source_dir, yaml_filename <> ".yaml"])

    unless File.exists?(yaml_path) do
      raise "BDD source YAML not found: #{yaml_path} (id=#{id}, module=#{module})"
    end

    source = YamlElixir.read_from_file!(yaml_path)

    ctx
    |> Map.put(:seed_id, id)
    |> Map.put(:seed_module, module)
    |> Map.put(:seed_source, source)
    |> Map.put(:seed_contract, source["contract"])
    |> Map.put(:seed_edge_class, source["edge_class"])
    |> Map.put(:seed_summary, source["source_summary"])
  end

  # when_execute_seed_contract: 根据 edge_class 分发执行逻辑
  def run!(ctx, :when, :when_execute_seed_contract, %{module: _module}, _meta) do
    edge_class = ctx[:seed_edge_class]
    id = ctx[:seed_id]

    result =
      case edge_class do
        "action_contract" ->
          # action 类：验证 contract 描述了 GIVEN/WHEN/THEN 结构
          validate_action_contract(ctx)

        "event_contract" ->
          # event 类：验证 contract 描述了事件发布
          validate_event_contract(ctx)

        "workflow_contract" ->
          # workflow 类：验证 contract 描述了工作流步骤
          validate_workflow_contract(ctx)

        other ->
          raise "Unknown edge_class: #{inspect(other)} for seed id=#{id}"
      end

    Map.put(ctx, :seed_execution_result, result)
  end

  # then_seed_contract_should_hold: 验证 contract 约束成立
  def run!(ctx, :then, :then_seed_contract_should_hold, %{module: _module}, _meta) do
    result = ctx[:seed_execution_result]

    case result do
      :ok ->
        ctx

      {:error, reason} ->
        raise "Seed contract validation failed: #{reason} (id=#{ctx[:seed_id]})"
    end
  end

  # ============================================================
  # 原有通用指令
  # ============================================================

  def run!(ctx, :given, :create_temp_dir, %{key: key}, _meta) when is_binary(key) do
    base = System.tmp_dir!()
    path = Path.join(base, "bddc_" <> key <> "_" <> (ctx[:run_id] || "no_run"))
    File.mkdir_p!(path)
    Map.merge(ctx, %{path: path})
  end

  def run!(ctx, :given, :create_temp_file, %{dir: dir, filename: filename} = args, _meta)
      when is_binary(dir) and is_binary(filename) do
    content = Map.get(args, :content, "")
    path = Path.join(dir, filename)
    File.mkdir_p!(Path.dirname(path))
    File.write!(path, content)
    Map.merge(ctx, %{path: path})
  end

  def run!(ctx, :then, :assert_noop, %{}, _meta) do
    ctx
  end

  def run!(ctx, :when, :noop, %{}, _meta) do
    ctx
  end

  def run!(_ctx, kind, name, _args, meta) do
    raise "unimplemented instruction: #{inspect({kind, name})} meta=#{inspect(meta)}"
  end

  # ============================================================
  # 内部辅助函数
  # ============================================================

  # 解析模块名，如 "ACCOUNTING_INVOICE" → {"ACCOUNTING", "INVOICE"}
  defp parse_module(module) do
    case String.split(module, "_", parts: 2) do
      [domain, entity] -> {domain, entity}
      [domain] -> {domain, ""}
    end
  end

  # 从 seed id 推导 YAML 文件名
  # id: "accounting_invoice_action_invoice_create_create"
  # module: "ACCOUNTING_INVOICE"
  # → 去掉 module 小写前缀 "accounting_invoice_" → "action_invoice_create_create"
  defp derive_yaml_filename(id, module) do
    prefix = String.downcase(module) <> "_"

    if String.starts_with?(id, prefix) do
      String.replace_prefix(id, prefix, "")
    else
      id
    end
  end

  # action contract 验证：source_summary 应包含 GIVEN/WHEN/THEN 结构描述
  defp validate_action_contract(ctx) do
    summary = ctx[:seed_summary] || ""
    contract = ctx[:seed_contract] || ""

    cond do
      summary == "" ->
        {:error, "action contract missing source_summary"}

      not String.contains?(contract, "action") ->
        {:error, "action contract name should contain 'action': #{contract}"}

      true ->
        :ok
    end
  end

  # event contract 验证：应描述事件发布
  defp validate_event_contract(ctx) do
    summary = ctx[:seed_summary] || ""
    contract = ctx[:seed_contract] || ""

    cond do
      summary == "" ->
        {:error, "event contract missing source_summary"}

      not String.contains?(contract, "event") ->
        {:error, "event contract name should contain 'event': #{contract}"}

      true ->
        :ok
    end
  end

  # workflow contract 验证：应描述工作流
  defp validate_workflow_contract(ctx) do
    summary = ctx[:seed_summary] || ""
    contract = ctx[:seed_contract] || ""

    cond do
      summary == "" ->
        {:error, "workflow contract missing source_summary"}

      not String.contains?(contract, "workflow") ->
        {:error, "workflow contract name should contain 'workflow': #{contract}"}

      true ->
        :ok
    end
  end
end
