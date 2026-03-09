defmodule UniboExPocWeb.GraphqlController do
  @moduledoc """
  GraphQL 通用调用入口骨架（由 UniBO 自动生成）。
  """

  use UniboExPocWeb, :controller
  alias UniboExPocWeb.Graphql.Runtime
  alias UniboExPocWeb.Graphql.RuntimeConfig

  def execute(conn, %{"query" => query} = params) when is_binary(query) do
    variables = Map.get(params, "variables") || %{}
    base_context = RuntimeConfig.build_context(%{conn: conn})

    case RuntimeConfig.authorize_request(base_context, query) do
      :ok ->
        dispatch_graphql(conn, query, variables, base_context)

      {:error, reason} ->
        conn
        |> put_status(:forbidden)
        |> json(%{"errors" => [forbidden_error(reason)]})
    end
  end

  def execute(conn, _params) do
    conn
    |> put_status(:bad_request)
    |> json(%{"errors" => [%{"message" => "query is required"}]})
  end

  defp dispatch_graphql(conn, query, variables, base_context) do
    case call_graphql(conn, query, variables, base_context) do
      {:ok, result} ->
        {status, payload} = normalize_result(result)

        conn
        |> put_status(status)
        |> json(payload)

      {:error, reason} ->
        conn
        |> put_status(:internal_server_error)
        |> json(%{"errors" => [%{"message" => inspect(reason), "code" => "INTERNAL_ERROR", "reason" => "internal_error"}]})
    end
  end

  def call_graphql(conn, query, variables \\ %{}, base_context \\ nil) do
    base_context =
      case base_context do
        nil -> RuntimeConfig.build_context(%{conn: conn})
        value -> value
      end

    loader = Runtime.new_loader(base_context)
    context = Map.put(base_context, :loader, loader)

    Absinthe.run(query, RuntimeConfig.schema_module(), variables: variables, context: context)
  end

  defp normalize_result(result) when is_map(result) do
    errors = map_get(result, :errors) || []

    if Enum.empty?(errors) do
      {:ok, result}
    else
      normalized_errors = Enum.map(errors, &normalize_error/1)
      has_forbidden = Enum.any?(normalized_errors, fn err -> map_get(err, :code) == "FORBIDDEN" end)
      status = if has_forbidden, do: :forbidden, else: :ok
      data = map_get(result, :data)
      payload = if is_nil(data), do: %{"errors" => normalized_errors}, else: %{"data" => data, "errors" => normalized_errors}
      {status, payload}
    end
  end

  defp normalize_result(result), do: {:ok, result}

  defp normalize_error(error) when is_map(error) do
    message = map_get(error, :message) || inspect(error)
    reason = normalized_error_reason(error, message)
    code = if forbidden_reason?(reason), do: "FORBIDDEN", else: "GRAPHQL_ERROR"
    path = map_get(error, :path)

    %{
      "message" => message,
      "code" => code,
      "reason" => reason,
      "extensions" => build_extensions(code, reason, path)
    }
  end

  defp normalize_error(error) do
    %{
      "message" => inspect(error),
      "code" => "GRAPHQL_ERROR",
      "reason" => "graphql_error",
      "extensions" => build_extensions("GRAPHQL_ERROR", "graphql_error", nil)
    }
  end

  defp forbidden_error(reason) do
    normalized_reason = normalize_reason(reason)
    %{
      "message" => forbidden_message(normalized_reason),
      "code" => "FORBIDDEN",
      "reason" => normalized_reason,
      "extensions" => build_extensions("FORBIDDEN", normalized_reason, nil)
    }
  end

  defp normalized_error_reason(error, message) do
    code = map_get(error, :code)
    reason = normalize_reason(map_get(error, :reason))
    message_downcase = String.downcase(to_string(message))

    cond do
      reason in [
        "forbidden",
        "unauthorized",
        "missing_actor_context",
        "insufficient_role",
        "abac_rule_not_satisfied",
        "invalid_abac_rule",
        "unsupported_postprocess_op"
      ] ->
        reason

      code in ["FORBIDDEN", "UNAUTHORIZED"] ->
        "forbidden"

      String.contains?(message_downcase, "abac rule") ->
        "invalid_abac_rule"

      String.contains?(message_downcase, "unsupported op") ->
        "unsupported_postprocess_op"

      String.contains?(message_downcase, "forbidden") ->
        "forbidden"

      String.contains?(message_downcase, "unauthorized") ->
        "unauthorized"

      true ->
        "graphql_error"
    end
  end

  defp normalize_reason(reason) when is_atom(reason), do: Atom.to_string(reason)

  defp normalize_reason(reason) when is_binary(reason) do
    reason
    |> String.trim()
    |> case do
      "" -> "forbidden"
      value -> value
    end
  end

  defp normalize_reason(_), do: "forbidden"

  defp forbidden_reason?(reason) do
    reason in [
      "forbidden",
      "unauthorized",
      "missing_actor_context",
      "insufficient_role",
      "abac_rule_not_satisfied"
    ]
  end

  defp build_extensions(code, reason, path) do
    base = %{"code" => code, "reason" => reason}

    case path do
      nil -> base
      value -> Map.put(base, "path", value)
    end
  end

  defp forbidden_message("missing_actor_context"), do: "missing actor context"
  defp forbidden_message(_), do: "forbidden"

  defp map_get(map, key) when is_map(map) and is_atom(key) do
    Map.get(map, key) || Map.get(map, Atom.to_string(key))
  end
end
