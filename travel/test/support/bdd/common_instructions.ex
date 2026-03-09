defmodule UniboExPoc.BDD.CommonInstructions do
  @moduledoc false

  @caps MapSet.new([
    :create_temp_dir,
    :create_temp_file,
    :noop,
    :assert_noop,
    :given_seed_context,
    :when_execute_seed_contract,
    :then_seed_contract_should_hold
  ])
  def capabilities, do: @caps

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

  # 中文注释：seed DSL 的最小运行时桩实现，先保证可编译可执行。
  def run!(ctx, :given, :given_seed_context, %{id: id, module: mod}, _meta)
      when is_binary(id) and is_binary(mod) do
    ctx
    |> Map.put(:seed_id, id)
    |> Map.put(:seed_module, mod)
  end

  def run!(ctx, :when, :when_execute_seed_contract, %{module: mod}, _meta) when is_binary(mod) do
    Map.put(ctx, :seed_executed_module, mod)
  end

  def run!(ctx, :then, :then_seed_contract_should_hold, %{module: mod}, _meta)
      when is_binary(mod) do
    expected = Map.get(ctx, :seed_module)

    if is_nil(expected) or expected == mod do
      ctx
    else
      raise "seed module mismatch: expected=#{inspect(expected)} got=#{inspect(mod)}"
    end
  end

  def run!(_ctx, kind, name, _args, meta) do
    raise "unimplemented instruction: #{inspect({kind, name})} meta=#{inspect(meta)}"
  end
end
