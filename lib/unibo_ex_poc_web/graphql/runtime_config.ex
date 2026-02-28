defmodule UniboExPocWeb.Graphql.RuntimeConfig do
  @moduledoc """
  应用侧 GraphQL 配置入口（由 UniBO 自动生成）。

  通过 `config/*.exs` 配置本模块可覆盖默认行为，无需改动生成代码：

      config :unibo_ex_poc, UniboExPocWeb.Graphql.RuntimeConfig,
        source: :default,
        schema: UniboExPocWeb.Schema,
        manifest: "priv/unibo/graphql/manifest.json",
        context_builder: {MyApp.GraphqlHooks, :build_context},
        loader: {MyApp.GraphqlHooks, :load},
        resolver: {MyApp.GraphqlHooks, :resolve}
  """

  @app :unibo_ex_poc
  @default_source :default
  alias Plug.Conn
  alias UniboExPoc.PurchasingV2.Actor

  def source_name do
    Keyword.get(config(), :source, @default_source)
  end

  def schema_module do
    Keyword.get(config(), :schema, UniboExPocWeb.Schema)
  end

  def manifest_path do
    Keyword.get(config(), :manifest, "priv/unibo/graphql/manifest.json")
  end

  def manifest do
    Unibo.Graphql.Manifest.load!(manifest_path())
  end

  def build_context(context) when is_map(context) do
    context = maybe_put_actor(context)
    hook = Keyword.get(config(), :context_builder)
    apply_optional_hook(hook, [context], context)
  end

  def load(batch, inputs) do
    hook = Keyword.get(config(), :loader)
    apply_optional_hook(hook, [batch, inputs], default_load(batch, inputs))
  end

  def resolve(meta, parent, args, resolution) do
    hook = Keyword.get(config(), :resolver)

    apply_optional_hook(
      hook,
      [meta, parent, args, resolution],
      {:ok, %{meta: meta, args: args, parent: parent, manifest: manifest()}}
    )
  end

  defp default_load(batch, inputs) do
    Enum.into(inputs, %{}, fn input -> {input, %{batch: batch}} end)
  end

  # 通过请求头透传 actor，供 Ash Policy 使用
  defp maybe_put_actor(%{conn: %Conn{} = conn} = context) do
    case build_actor_from_headers(conn) do
      nil -> context
      actor -> Map.put(context, :actor, actor)
    end
  end

  defp maybe_put_actor(context), do: context

  defp build_actor_from_headers(conn) do
    actor_id = header_value(conn, "x-actor-id")
    role = header_value(conn, "x-actor-role")

    with true <- is_binary(actor_id) and actor_id != "",
         true <- is_binary(role),
         {:ok, role_atom} <- normalize_role(role) do
      %Actor{id: actor_id, role: role_atom}
    else
      _ -> nil
    end
  end

  defp header_value(conn, key) do
    conn
    |> Conn.get_req_header(key)
    |> List.first()
    |> case do
      nil -> nil
      value -> String.trim(value)
    end
  end

  defp normalize_role("buyer"), do: {:ok, :buyer}
  defp normalize_role("admin"), do: {:ok, :admin}
  defp normalize_role("supplier"), do: {:ok, :supplier}
  defp normalize_role("viewer"), do: {:ok, :viewer}
  defp normalize_role(_), do: :error

  defp config do
    Application.get_env(@app, __MODULE__, [])
  end

  defp apply_optional_hook(nil, _args, default), do: default

  defp apply_optional_hook({module, function}, args, default)
       when is_atom(module) and is_atom(function) do
    if function_exported?(module, function, length(args)) do
      apply(module, function, args)
    else
      default
    end
  end

  defp apply_optional_hook(_, _args, default), do: default
end
