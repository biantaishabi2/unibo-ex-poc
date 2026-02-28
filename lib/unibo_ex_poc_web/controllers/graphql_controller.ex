defmodule UniboExPocWeb.GraphqlController do
  @moduledoc """
  GraphQL 通用调用入口骨架（由 UniBO 自动生成）。
  """

  use UniboExPocWeb, :controller
  alias UniboExPocWeb.Graphql.Runtime
  alias UniboExPocWeb.Graphql.RuntimeConfig

  def execute(conn, %{"query" => query} = params) when is_binary(query) do
    variables = Map.get(params, "variables") || %{}

    case call_graphql(conn, query, variables) do
      {:ok, result} ->
        json(conn, result)

      {:error, reason} ->
        conn
        |> put_status(:internal_server_error)
        |> json(%{"errors" => [%{"message" => inspect(reason)}]})
    end
  end

  def execute(conn, _params) do
    conn
    |> put_status(:bad_request)
    |> json(%{"errors" => [%{"message" => "query is required"}]})
  end

  def call_graphql(conn, query, variables \\ %{}) do
    base_context = RuntimeConfig.build_context(%{conn: conn})
    loader = Runtime.new_loader(base_context)
    context = Map.put(base_context, :loader, loader)

    Absinthe.run(query, RuntimeConfig.schema_module(), variables: variables, context: context)
  end
end
