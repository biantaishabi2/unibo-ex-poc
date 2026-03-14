defmodule HospitalSchedulingWeb.GraphqlController do
  @moduledoc """
  GraphQL 通用调用入口骨架（由 UniBO 自动生成）。
  """

  use HospitalSchedulingWeb, :controller
  alias HospitalSchedulingWeb.Graphql.Runtime
  alias HospitalSchedulingWeb.Graphql.RuntimeConfig

  def execute(conn, %{"query" => query} = params) when is_binary(query) do
    variables = Map.get(params, "variables") || %{}
    base_context = RuntimeConfig.build_context(%{conn: conn})

    case RuntimeConfig.runtime_consistency_error() do
      nil ->
        case RuntimeConfig.authorize_request(base_context, query) do
          :ok ->
            dispatch_graphql(conn, query, variables, base_context)

          {:error, reason} ->
            conn
            |> put_status(:forbidden)
            |> json(%{"errors" => [forbidden_error(reason)]})
        end

      error ->
        conn
        |> put_status(:internal_server_error)
        |> json(%{"errors" => [error]})
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
        {status, payload} = normalize_result(result, query)

        conn
        |> put_status(status)
        |> json(payload)

      {:error, reason} ->
        conn
        |> put_status(:internal_server_error)
        |> json(%{
          "errors" => [
            %{
              "message" => inspect(reason),
              "code" => "INTERNAL_ERROR",
              "reason" => "internal_error"
            }
          ]
        })
    end
  end

  def call_graphql(conn, query, variables \\ %{}, base_context \\ nil) do
    base_context =
      case base_context do
        nil -> RuntimeConfig.build_context(%{conn: conn})
        value -> value
      end

    case RuntimeConfig.runtime_consistency_error() do
      nil ->
        loader = Runtime.new_loader(base_context)
        context = Map.put(base_context, :loader, loader)

        case RuntimeConfig.tenant_error(context) do
          nil ->
            if graphql_operation_kind(query) == :query do
              with_org_scope_cache(fn ->
                Absinthe.run(query, RuntimeConfig.schema_module(),
                  variables: variables,
                  context: context
                )
              end)
            else
              Absinthe.run(query, RuntimeConfig.schema_module(),
                variables: variables,
                context: context
              )
            end

          error ->
            {:ok, %{errors: [error]}}
        end

      error ->
        {:ok, %{errors: [error]}}
    end
  end

  defp with_org_scope_cache(fun) when is_function(fun, 0) do
    case org_scope_module() do
      nil -> fun.()
      module -> apply(module, :with_scope_cache, [fun])
    end
  end

  defp graphql_operation_kind(query) when is_binary(query) do
    normalized =
      query
      |> String.trim_leading()
      |> String.downcase()

    cond do
      String.starts_with?(normalized, "mutation") -> :mutation
      String.starts_with?(normalized, "subscription") -> :subscription
      true -> :query
    end
  end

  defp graphql_operation_kind(_), do: :query

  defp org_scope_module do
    module = HospitalScheduling.Organization.OrgScope

    if Code.ensure_loaded?(module) and function_exported?(module, :with_scope_cache, 1) do
      module
    else
      nil
    end
  end

  defp normalize_result(result, query) when is_map(result) do
    errors = map_get(result, :errors) || []
    operation_field = query_root_field(query)

    if Enum.empty?(errors) do
      {:ok, result}
    else
      normalized_errors = Enum.map(errors, &normalize_error(&1, operation_field))

      has_forbidden =
        Enum.any?(normalized_errors, fn err -> map_get(err, :code) == "FORBIDDEN" end)

      status = if has_forbidden, do: :forbidden, else: :ok
      data = map_get(result, :data)

      payload =
        if is_nil(data),
          do: %{"errors" => normalized_errors},
          else: %{"data" => data, "errors" => normalized_errors}

      {status, payload}
    end
  end

  defp normalize_result(result, _query), do: {:ok, result}

  defp normalize_error(error, operation_field) when is_map(error) do
    message = map_get(error, :message) || inspect(error)
    reason = normalized_error_reason(error, message)
    code = normalized_error_code(error, reason)
    path = map_get(error, :path)
    extensions = map_get(error, :extensions)
    hint = runtime_error_hint(reason, operation_field)
    doc_url = runtime_error_doc_url(reason, operation_field)

    %{
      "message" => message,
      "code" => code,
      "reason" => reason,
      "extensions" =>
        merge_extensions(extensions, build_extensions(code, reason, path, hint, doc_url))
    }
  end

  defp normalize_error(error, operation_field) do
    hint = runtime_error_hint("graphql_error", operation_field)
    doc_url = runtime_error_doc_url("graphql_error", operation_field)

    %{
      "message" => inspect(error),
      "code" => "GRAPHQL_ERROR",
      "reason" => "graphql_error",
      "extensions" => build_extensions("GRAPHQL_ERROR", "graphql_error", nil, hint, doc_url)
    }
  end

  defp forbidden_error(reason) do
    normalized_reason = normalize_reason(reason)

    %{
      "message" => forbidden_message(normalized_reason),
      "code" => "FORBIDDEN",
      "reason" => normalized_reason,
      "extensions" =>
        build_extensions(
          "FORBIDDEN",
          normalized_reason,
          nil,
          runtime_error_hint(normalized_reason, nil),
          runtime_error_doc_url(normalized_reason, nil)
        )
    }
  end

  defp normalized_error_reason(error, message) do
    code = map_get(error, :code)
    reason = normalize_reason(map_get(error, :reason))
    message_downcase = String.downcase(to_string(message))

    cond do
      reason in ["tenant_required", "invalid_tenant_id", "tenant_resolution_failed"] ->
        reason

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

      String.contains?(message_downcase, "tenantrequired") ->
        "tenant_required"

      String.contains?(message_downcase, "tenant required") ->
        "tenant_required"

      String.contains?(message_downcase, "invalid tenant id") ->
        "invalid_tenant_id"

      String.contains?(message_downcase, "abac rule") ->
        "invalid_abac_rule"

      String.contains?(message_downcase, "unsupported op") ->
        "unsupported_postprocess_op"

      String.contains?(message_downcase, "must be present") ->
        "invalid_arguments"

      String.contains?(message_downcase, "is required") ->
        "invalid_arguments"

      String.contains?(message_downcase, "required") ->
        "invalid_arguments"

      String.contains?(message_downcase, "forbidden") ->
        "forbidden"

      String.contains?(message_downcase, "unauthorized") ->
        "unauthorized"

      true ->
        "graphql_error"
    end
  end

  defp normalized_error_code(error, reason) do
    incoming = normalize_code_value(map_get(error, :code))

    cond do
      incoming in ["FORBIDDEN", "BAD_USER_INPUT", "GRAPHQL_ERROR", "UNAUTHORIZED"] ->
        if incoming == "UNAUTHORIZED", do: "FORBIDDEN", else: incoming

      forbidden_reason?(reason) ->
        "FORBIDDEN"

      reason in [
        "tenant_required",
        "invalid_tenant_id",
        "tenant_resolution_failed",
        "invalid_arguments"
      ] ->
        "BAD_USER_INPUT"

      true ->
        "GRAPHQL_ERROR"
    end
  end

  defp normalize_code_value(nil), do: ""
  defp normalize_code_value(value) when is_binary(value), do: String.trim(value)

  defp normalize_code_value(value) when is_atom(value),
    do: value |> Atom.to_string() |> String.trim()

  defp normalize_code_value(value), do: value |> to_string() |> String.trim()

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

  defp build_extensions(code, reason, path, hint, doc_url) do
    base = %{"code" => code, "reason" => reason}

    base =
      case hint do
        nil -> base
        value -> Map.put(base, "hint", value)
      end

    base =
      case doc_url do
        nil -> base
        value -> Map.put(base, "doc_url", value)
      end

    case path do
      nil -> base
      value -> Map.put(base, "path", value)
    end
  end

  defp runtime_error_hint("invalid_tenant_id", _operation_field),
    do: "x-tenant-id 必须是合法 UUID，或改用 x-tenant-code / x-tenant-slug"

  defp runtime_error_hint("tenant_required", _operation_field),
    do: "请提供 x-tenant-id，或使用 x-tenant-code / x-tenant-slug"

  defp runtime_error_hint("tenant_resolution_failed", _operation_field),
    do: "请检查 tenant alias 是否存在，或改用 x-tenant-id"

  defp runtime_error_hint("invalid_arguments", operation_field) when is_binary(operation_field) do
    case contract_field_doc(operation_field) do
      %{"conditional_requirements" => requirements}
      when is_list(requirements) and requirements != [] ->
        "请检查条件必填规则：" <> Enum.join(Enum.map(requirements, &to_string/1), "; ")

      %{"summary" => summary} when is_binary(summary) and summary != "" ->
        summary

      _ ->
        "请检查必填参数和调用契约"
    end
  end

  defp runtime_error_hint("graphql_error", operation_field) when is_binary(operation_field) do
    runtime_error_hint("invalid_arguments", operation_field)
  end

  defp runtime_error_hint(_reason, _operation_field), do: nil

  defp runtime_error_doc_url(reason, _operation_field)
       when reason in ["invalid_tenant_id", "tenant_required", "tenant_resolution_failed"] do
    "graphql://contract/common/tenant"
  end

  defp runtime_error_doc_url(_reason, operation_field) when is_binary(operation_field) do
    case contract_field_doc(operation_field) do
      %{"doc_url" => doc_url} when is_binary(doc_url) and doc_url != "" -> doc_url
      _ -> nil
    end
  end

  defp runtime_error_doc_url(_reason, _operation_field), do: nil

  defp contract_field_doc(operation_field) when is_binary(operation_field) do
    RuntimeConfig.manifest()
    |> map_get("fields")
    |> case do
      fields when is_list(fields) ->
        Enum.find(fields, fn field ->
          normalize_text(map_get(field, "field")) == normalize_text(operation_field)
        end)

      _ ->
        nil
    end
  end

  defp contract_field_doc(_operation_field), do: nil

  defp merge_extensions(existing, generated) when is_map(existing) and is_map(generated) do
    Map.merge(generated, existing)
  end

  defp merge_extensions(_existing, generated), do: generated

  defp query_root_field(query) when is_binary(query) do
    case Regex.run(
           ~r/\{\s*(?:[_A-Za-z][_0-9A-Za-z]*\s*:\s*)?([_A-Za-z][_0-9A-Za-z]*)/,
           query
         ) do
      [_, field_name] -> field_name
      _ -> nil
    end
  end

  defp query_root_field(_), do: nil

  defp normalize_text(nil), do: ""
  defp normalize_text(value) when is_binary(value), do: String.trim(value)
  defp normalize_text(value) when is_atom(value), do: value |> Atom.to_string() |> String.trim()
  defp normalize_text(value), do: value |> to_string() |> String.trim()

  defp forbidden_message("missing_actor_context"), do: "missing actor context"
  defp forbidden_message(_), do: "forbidden"

  defp map_get(map, key) when is_map(map) and is_atom(key) do
    Map.get(map, key) || Map.get(map, Atom.to_string(key))
  end

  defp map_get(map, key) when is_map(map) and is_binary(key) do
    Map.get(map, key) || Map.get(map, String.to_atom(key))
  end

  defp map_get(_map, _key), do: nil
end
