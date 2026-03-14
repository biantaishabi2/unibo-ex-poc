defmodule HospitalSchedulingWeb.Graphql.RuntimeConfig do
  @moduledoc """
  应用侧 GraphQL 配置入口（由 UniBO 自动生成）。

  通过 `config/*.exs` 配置本模块可覆盖默认行为，无需改动生成代码：

      config :hospital_scheduling, HospitalSchedulingWeb.Graphql.RuntimeConfig,
        source: :default,
        schema: HospitalSchedulingWeb.Schema,
        manifest: "priv/unibo/graphql/manifest.json",
        frontend_manifest: "priv/unibo/frontend_manifest.v1.json",
        entry_auth_matrix: [query: :compat, mutation: :strict, subscription: :compat],
        public_query_whitelist: ["health"],
        context_builder: {MyApp.GraphqlHooks, :build_context},
        tenant_resolver: {MyApp.GraphqlHooks, :resolve_tenant},

        tenant_id_format: :opaque,
        demo_tenant_id: "00000000-0000-0000-0000-000000000000",
        loader: {MyApp.GraphqlHooks, :load},
        resolver: {MyApp.GraphqlHooks, :resolve},
        postprocess_plan: {MyApp.GraphqlHooks, :postprocess_plan},
        authz_audit_logger: {MyApp.GraphqlHooks, :authz_audit},
        postprocess_enabled: true
  """

  @app :hospital_scheduling
  @default_source :default
  alias HospitalSchedulingWeb.Graphql.ActorContext

  def source_name do
    Keyword.get(config(), :source, @default_source)
  end

  def schema_module do
    Keyword.get(config(), :schema, HospitalSchedulingWeb.Schema)
  end

  def runtime_consistency_error do
    invalid_domains =
      schema_module()
      |> runtime_schema_domains()
      |> Enum.reject(&ash_domain_module?/1)

    case invalid_domains do
      [] ->
        nil

      domains ->
        domain_names = Enum.map(domains, &inspect/1)

        %{
          message: "GraphQL 生成物一致性检查失败：检测到缺失或无效的 domain 模块，疑似只同步了部分 compile-project 生成物",
          code: "GRAPHQL_RUNTIME_SYNC_ERROR",
          reason: "generated_artifacts_out_of_sync",
          extensions: %{
            code: "GRAPHQL_RUNTIME_SYNC_ERROR",
            reason: "generated_artifacts_out_of_sync",
            hint: "请整套同步 lib/、config/config.exs、test/support，不要只单独替换 schema.ex",
            domains: domain_names
          }
        }
    end
  end

  def manifest_path do
    Keyword.get(config(), :manifest, "priv/unibo/graphql/manifest.json")
  end

  def manifest do
    safe_manifest_load(manifest_path())
  end

  def frontend_manifest_path do
    Keyword.get(config(), :frontend_manifest, "priv/unibo/frontend_manifest.v1.json")
  end

  def frontend_manifest do
    safe_manifest_load(frontend_manifest_path())
  end

  def graphql_contract(field_or_doc_url) when is_binary(field_or_doc_url) do
    field_or_doc_url = normalize_string(field_or_doc_url)

    with false <- field_or_doc_url == "",
         %{} = field <-
           graphql_builtin_contract(field_or_doc_url) || manifest_field_contract(field_or_doc_url) do
      %{}
      |> Map.put(:field, normalize_string(map_get(field, "field")))
      |> put_present(:summary, map_get(field, "summary"))
      |> put_present(:doc_url, map_get(field, "doc_url"))
      |> Map.put(:required_headers, normalize_string_list(map_get(field, "required_headers")))
      |> Map.put(
        :conditional_requirements,
        normalize_string_list(map_get(field, "conditional_requirements"))
      )
      |> put_present(:body, graphql_contract_body(map_get(field, "doc_url")))
    else
      _ -> nil
    end
  end

  def graphql_contract(_field_or_doc_url), do: nil

  def build_context(context) when is_map(context) do
    normalized =
      context
      |> ensure_tenant_context()
      |> ensure_context_envelope()
      |> ensure_actor_context()
      |> ensure_correlation_context()

    hook = Keyword.get(config(), :context_builder)
    apply_optional_hook(hook, [normalized], normalized)
  end

  def tenant_error(context) when is_map(context) do
    case context_value(context, :tenant_error) || context_value(context, "tenant_error") do
      %{} = error -> error
      _ -> nil
    end
  end

  def tenant_error(_), do: nil

  defp runtime_schema_domains(schema_module) when is_atom(schema_module) do
    if function_exported?(schema_module, :unibo_runtime_domains, 0) do
      schema_module.unibo_runtime_domains()
      |> List.wrap()
    else
      []
    end
  end

  defp runtime_schema_domains(_schema_module), do: []

  defp ash_domain_module?(module) when is_atom(module) do
    Code.ensure_loaded?(module) and function_exported?(module, :spark_dsl_config, 0)
  end

  defp ash_domain_module?(_module), do: false

  def authorize_request(context, query) do
    operation = operation_kind(query)
    mode = entry_auth_mode(operation)

    cond do
      mode == :compat and actor_present?(context) ->
        emit_authz_audit(context, build_authz_audit(context, query, mode, :allow, nil, nil, nil))
        :ok

      mode == :compat ->
        emit_authz_audit(
          context,
          build_authz_audit(
            context,
            query,
            mode,
            :warn,
            "FORBIDDEN",
            "missing_actor_context",
            "missing actor context (compat warning)"
          )
        )

        :ok

      operation == :query and public_query_whitelisted?(query) ->
        emit_authz_audit(context, build_authz_audit(context, query, mode, :allow, nil, nil, nil))
        :ok

      actor_present?(context) ->
        emit_authz_audit(context, build_authz_audit(context, query, mode, :allow, nil, nil, nil))
        :ok

      true ->
        emit_authz_audit(
          context,
          build_authz_audit(
            context,
            query,
            mode,
            :deny,
            "FORBIDDEN",
            "missing_actor_context",
            "missing actor context"
          )
        )

        {:error, :missing_actor_context}
    end
  end

  defp build_authz_audit(context, query, mode, decision, code, reason, message) do
    action = operation_kind(query) |> to_string()
    resource = query_root_field(query) || action
    request_id = request_id_from_context(context)
    trace_id = trace_id_from_context(context)

    request_id =
      cond do
        request_id == "" and trace_id != "" -> trace_id
        true -> request_id
      end

    trace_id =
      cond do
        trace_id == "" and request_id != "" -> request_id
        true -> trace_id
      end

    request_id = if request_id == "", do: "no_request_id", else: request_id
    trace_id = if trace_id == "", do: "no_trace_id", else: trace_id

    %{
      "timestamp" => DateTime.utc_now() |> DateTime.to_iso8601(),
      "mode" => to_string(mode),
      "decision" => to_string(decision),
      "code" => normalize_audit_code(decision, code),
      "reason" => normalize_audit_reason(decision, reason),
      "message" => normalize_audit_message(decision, reason, message),
      "trace_id" => trace_id,
      "request_id" => request_id,
      "actor" => actor_snapshot(actor(context)),
      "tenant" => tenant_snapshot(context),
      "action" => action,
      "resource" => resource
    }
  end

  defp emit_authz_audit(context, audit) when is_map(audit) do
    hook = Keyword.get(config(), :authz_audit_logger)
    _ = apply_optional_hook(hook, [audit, context], :ok)
    :ok
  end

  defp request_id_from_context(context) do
    request_id =
      context_value(context, :request_id) ||
        context_value(context, "request_id") ||
        correlation_value(context, "request_id") ||
        header_value(context, "x-request-id")

    normalize_string(request_id)
  end

  defp trace_id_from_context(context) do
    trace_id =
      context_value(context, :trace_id) ||
        context_value(context, "trace_id") ||
        correlation_value(context, "trace_id") ||
        header_value(context, "x-trace-id")

    normalize_string(trace_id)
  end

  defp tenant_snapshot(context) when is_map(context) do
    tenant_scope = scope_value(context, "tenant")
    tenant = context_value(context, :tenant) || context_value(context, "tenant")
    tenant_id = context_value(context, :tenant_id) || context_value(context, "tenant_id")

    cond do
      is_map(tenant_scope) and map_size(tenant_scope) > 0 ->
        tenant_scope
        |> normalize_map()
        |> ensure_tenant_snapshot_ids()

      is_map(tenant) ->
        tenant
        |> normalize_map()
        |> ensure_tenant_snapshot_ids()

      normalize_string(tenant_id) != "" ->
        id = normalize_string(tenant_id)
        %{"id" => id, "tenant_id" => id}

      normalize_string(tenant) != "" ->
        id = normalize_string(tenant)
        %{"id" => id, "tenant_id" => id}

      true ->
        %{}
    end
  end

  defp tenant_snapshot(_), do: %{}

  defp actor_snapshot(actor) when is_map(actor) do
    actor
    |> Enum.into(%{}, fn {key, value} -> {to_string(key), normalize_string(value)} end)
    |> Map.reject(fn {_key, value} -> value == "" end)
  end

  defp actor_snapshot(_), do: %{}

  defp normalize_audit_code(decision, code) do
    case {to_string(decision), normalize_string(code)} do
      {_, value} when value != "" -> value
      {"allow", _} -> "ALLOW"
      _ -> "FORBIDDEN"
    end
  end

  defp normalize_audit_reason(decision, reason) do
    case {to_string(decision), normalize_string(reason)} do
      {_, value} when value != "" -> value
      {"allow", _} -> "allowed"
      _ -> "forbidden"
    end
  end

  defp normalize_audit_message(decision, reason, message) do
    normalized = normalize_string(message)

    cond do
      normalized != "" ->
        normalized

      to_string(decision) == "allow" ->
        "allowed"

      true ->
        forbidden_message(normalize_audit_reason(decision, reason))
    end
  end

  defp forbidden_message("missing_actor_context"), do: "missing actor context"
  defp forbidden_message(_), do: "forbidden"

  defp context_value(context, key) when is_map(context), do: Map.get(context, key)
  defp context_value(_, _), do: nil

  defp header_value(context, header_name) do
    conn = context_value(context, :conn) || context_value(context, "conn")

    case conn do
      %Plug.Conn{} = conn ->
        conn
        |> Plug.Conn.get_req_header(header_name)
        |> List.first()

      _ ->
        nil
    end
  end

  defp normalize_string(nil), do: ""
  defp normalize_string(value) when is_binary(value), do: String.trim(value)
  defp normalize_string(value) when is_atom(value), do: value |> Atom.to_string() |> String.trim()
  defp normalize_string(value) when is_integer(value), do: Integer.to_string(value)

  defp normalize_string(value) when is_float(value),
    do: :erlang.float_to_binary(value, [:compact, decimals: 6])

  defp normalize_string(_), do: ""

  defp normalize_string_list(values) when is_list(values) do
    values
    |> Enum.map(&normalize_string/1)
    |> Enum.filter(&(&1 != ""))
  end

  defp normalize_string_list(_values), do: []

  defp map_get(map, key) when is_map(map) and is_atom(key) do
    Map.get(map, key) || Map.get(map, Atom.to_string(key))
  end

  defp map_get(map, key) when is_map(map) and is_binary(key) do
    Map.get(map, key) || Map.get(map, String.to_atom(key))
  end

  defp map_get(_map, _key), do: nil

  # 语义上下文契约（V2）:
  # principal / scope / authz / correlation / extensions
  def context_envelope(context) when is_map(context) do
    raw = context_value(context, :context_envelope) || context_value(context, "context_envelope")

    case normalize_context_envelope(raw) do
      nil -> normalize_legacy_context_envelope(context)
      value -> value
    end
  end

  def context_envelope(_), do: nil

  defp ensure_context_envelope(context) do
    case context_envelope(context) do
      nil ->
        context

      envelope ->
        context
        |> Map.put(:context_envelope, envelope)
        |> Map.put_new(:principal, map_value(envelope, "principal"))
        |> Map.put_new(:scope, map_value(envelope, "scope"))
        |> Map.put_new(:authz, map_value(envelope, "authz"))
        |> Map.put_new(:correlation, map_value(envelope, "correlation"))
        |> Map.put_new(:extensions, map_value(envelope, "extensions"))
    end
  end

  defp normalize_context_envelope(raw) when is_map(raw) do
    principal = normalize_map(map_value(raw, "principal"))
    scope = normalize_map(map_value(raw, "scope"))
    authz = normalize_authz(map_value(raw, "authz"))
    correlation = normalize_map(map_value(raw, "correlation"))
    extensions = normalize_map(map_value(raw, "extensions"))

    envelope = %{
      "principal" => principal,
      "scope" => scope,
      "authz" => authz,
      "correlation" => correlation,
      "extensions" => extensions
    }

    if Enum.all?(Map.values(envelope), fn section -> section == %{} end), do: nil, else: envelope
  end

  defp normalize_context_envelope(_), do: nil

  defp normalize_legacy_context_envelope(context) when is_map(context) do
    principal =
      %{}
      |> put_present(
        "id",
        context_value(context, :user_id) || context_value(context, "user_id") ||
          context_value(context, :actor_id) || context_value(context, "actor_id") ||
          header_value(context, "x-user-id") || header_value(context, "x-actor-id")
      )
      |> put_present(
        "party_id",
        context_value(context, :party_id) || context_value(context, "party_id") ||
          header_value(context, "x-party-id") || header_value(context, "x-actor-party-id")
      )
      |> put_present(
        "member_id",
        context_value(context, :member_id) || context_value(context, "member_id") ||
          header_value(context, "x-member-id")
      )
      |> put_present(
        "type",
        context_value(context, :principal_type) || context_value(context, "principal_type") ||
          "user"
      )

    tenant_id =
      case tenant_error(context) do
        nil ->
          context_value(context, :tenant_id) ||
            context_value(context, "tenant_id") ||
            context_value(context, :tenant) ||
            context_value(context, "tenant") ||
            header_value(context, "x-tenant-id") ||
            header_value(context, "x-tenant-code") ||
            header_value(context, "x-tenant-slug")

        _error ->
          context_value(context, :tenant_id) ||
            context_value(context, "tenant_id") ||
            context_value(context, :tenant) ||
            context_value(context, "tenant")
      end

    shop_id =
      context_value(context, :current_shop_id) ||
        context_value(context, "current_shop_id") ||
        context_value(context, :shop_id) ||
        context_value(context, "shop_id") ||
        header_value(context, "x-shop-id")

    org_id =
      context_value(context, :enterprise_id) ||
        context_value(context, "enterprise_id") ||
        header_value(context, "x-enterprise-id")

    scope =
      %{}
      |> put_present("tenant", tenant_scope_map(tenant_id))
      |> put_present("shop", id_scope_map("shop_id", shop_id))
      |> put_present("org", id_scope_map("enterprise_id", org_id))

    authz = normalize_authz(%{"roles" => extract_roles(context)})

    correlation =
      %{}
      |> put_present(
        "request_id",
        context_value(context, :request_id) || context_value(context, "request_id") ||
          header_value(context, "x-request-id")
      )
      |> put_present(
        "trace_id",
        context_value(context, :trace_id) || context_value(context, "trace_id") ||
          header_value(context, "x-trace-id")
      )

    envelope = %{
      "principal" => principal,
      "scope" => scope,
      "authz" => authz,
      "correlation" => correlation,
      "extensions" => %{}
    }

    if Enum.all?(Map.values(envelope), fn section -> section == %{} end), do: nil, else: envelope
  end

  defp normalize_legacy_context_envelope(_), do: nil

  defp tenant_scope_map(value) do
    normalized = normalize_string(value)

    if normalized == "" do
      %{}
    else
      %{"id" => normalized, "tenant_id" => normalized}
    end
  end

  defp id_scope_map(id_key, value) do
    normalized = normalize_string(value)

    if normalized == "" do
      %{}
    else
      %{"id" => normalized, id_key => normalized}
    end
  end

  defp ensure_tenant_snapshot_ids(snapshot) when is_map(snapshot) do
    tenant_id =
      map_value(snapshot, "id") ||
        map_value(snapshot, "tenant_id")

    case normalize_string(tenant_id) do
      "" -> snapshot
      id -> snapshot |> Map.put_new("id", id) |> Map.put_new("tenant_id", id)
    end
  end

  defp ensure_tenant_snapshot_ids(snapshot), do: snapshot

  defp normalize_authz(raw) do
    base = normalize_map(raw)
    roles = normalize_roles(map_value(base, "roles"))

    case roles do
      [] -> Map.delete(base, "roles")
      value -> Map.put(base, "roles", value)
    end
  end

  defp normalize_roles(nil), do: []

  defp normalize_roles(value) when is_binary(value),
    do:
      value
      |> String.split(",", trim: true)
      |> Enum.map(&normalize_string/1)
      |> Enum.reject(&(&1 == ""))

  defp normalize_roles(value) when is_list(value),
    do: value |> Enum.map(&normalize_string/1) |> Enum.reject(&(&1 == ""))

  defp normalize_roles(_), do: []

  defp extract_roles(context) do
    raw =
      context_value(context, :roles) ||
        context_value(context, "roles") ||
        context_value(context, :actor_role) ||
        context_value(context, "actor_role") ||
        header_value(context, "x-roles") ||
        header_value(context, "x-actor-role")

    normalize_roles(raw)
  end

  defp normalize_map(raw) when is_map(raw) do
    Enum.reduce(raw, %{}, fn {key, value}, acc ->
      normalized_key = normalize_string(key)

      cond do
        normalized_key == "" ->
          acc

        is_map(value) ->
          nested = normalize_map(value)
          if nested == %{}, do: acc, else: Map.put(acc, normalized_key, nested)

        is_list(value) ->
          normalized_list =
            value
            |> Enum.map(&normalize_string/1)
            |> Enum.reject(&(&1 == ""))

          if normalized_list == [], do: acc, else: Map.put(acc, normalized_key, normalized_list)

        true ->
          normalized_value = normalize_string(value)
          if normalized_value == "", do: acc, else: Map.put(acc, normalized_key, normalized_value)
      end
    end)
  end

  defp normalize_map(_), do: %{}

  defp map_value(map, key) when is_map(map) do
    cond do
      is_atom(key) and Map.has_key?(map, key) ->
        Map.get(map, key)

      is_binary(key) and Map.has_key?(map, key) ->
        Map.get(map, key)

      true ->
        expected = normalize_string(key)

        case Enum.reduce_while(map, :not_found, fn {existing_key, value}, _acc ->
               if normalize_string(existing_key) == expected do
                 {:halt, {:found, value}}
               else
                 {:cont, :not_found}
               end
             end) do
          {:found, value} -> value
          _ -> nil
        end
    end
  end

  defp map_value(_map, _key), do: nil

  defp put_present(map, key, value) when is_map(value) do
    if value == %{}, do: map, else: Map.put(map, key, value)
  end

  defp put_present(map, key, value) do
    normalized = normalize_string(value)
    if normalized == "", do: map, else: Map.put(map, key, normalized)
  end

  defp scope_value(context, key) do
    context
    |> context_envelope()
    |> map_value("scope")
    |> map_value(key)
  end

  defp correlation_value(context, key) do
    context
    |> context_envelope()
    |> map_value("correlation")
    |> map_value(key)
  end

  defp principal_value(context) do
    context
    |> context_envelope()
    |> map_value("principal")
  end

  defp authz_value(context) do
    context
    |> context_envelope()
    |> map_value("authz")
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

  def postprocess_plan(meta, parent, args, resolution) do
    hook = Keyword.get(config(), :postprocess_plan)
    apply_optional_hook(hook, [meta, parent, args, resolution], default_postprocess_plan(meta))
  end

  def postprocess_enabled? do
    Keyword.get(config(), :postprocess_enabled, true)
  end

  defp default_postprocess_plan(meta) do
    merge_postprocess_plan(
      manifest_postprocess_plan(manifest(), meta),
      manifest_frontend_postprocess_plan(manifest(), frontend_manifest(), meta)
    )
  end

  defp safe_manifest_load(path) do
    mod = Unibo.Graphql.Manifest

    cond do
      Code.ensure_loaded?(mod) and function_exported?(mod, :safe_load, 1) ->
        apply(mod, :safe_load, [path]) || %{}

      Code.ensure_loaded?(mod) and function_exported?(mod, :load!, 1) ->
        try do
          apply(mod, :load!, [path])
        rescue
          _ -> %{}
        end

      true ->
        %{}
    end
  end

  defp manifest_postprocess_plan(manifest_data, meta) do
    mod = Unibo.Graphql.Manifest

    if Code.ensure_loaded?(mod) and function_exported?(mod, :postprocess_plan_for, 2) do
      apply(mod, :postprocess_plan_for, [manifest_data, meta])
    else
      nil
    end
  end

  defp manifest_frontend_postprocess_plan(manifest_data, frontend_data, meta) do
    mod = Unibo.Graphql.Manifest

    if Code.ensure_loaded?(mod) and function_exported?(mod, :frontend_postprocess_plan_for, 3) do
      apply(mod, :frontend_postprocess_plan_for, [manifest_data, frontend_data, meta])
    else
      nil
    end
  end

  defp merge_postprocess_plan(nil, nil), do: nil
  defp merge_postprocess_plan(left, nil), do: left
  defp merge_postprocess_plan(nil, right), do: right

  defp merge_postprocess_plan(left, right) when is_map(left) and is_map(right) do
    phases = [:resolve_children, :post, :finalize]

    Enum.reduce(phases, %{}, fn phase, acc ->
      phase_key = Atom.to_string(phase)

      merged =
        List.wrap(Map.get(left, phase) || Map.get(left, phase_key)) ++
          List.wrap(Map.get(right, phase) || Map.get(right, phase_key))

      if merged == [] do
        acc
      else
        Map.put(acc, phase_key, merged)
      end
    end)
  end

  defp merge_postprocess_plan(left, _right), do: left

  defp default_load(batch, inputs) do
    Enum.into(inputs, %{}, fn input -> {input, %{batch: batch}} end)
  end

  defp manifest_field_contract(field_name) when is_binary(field_name) do
    mod = Unibo.Graphql.Manifest
    manifest_data = manifest()
    lookup_key = graphql_contract_lookup_key(field_name)
    normalized_field_name = normalize_string(field_name)

    cond do
      Code.ensure_loaded?(mod) and function_exported?(mod, :field, 2) ->
        apply(mod, :field, [manifest_data, lookup_key])

      true ->
        manifest_data
        |> map_get("fields")
        |> case do
          fields when is_list(fields) ->
            Enum.find(fields, fn field ->
              normalize_string(map_get(field, "field")) == lookup_key or
                normalize_string(map_get(field, "doc_url")) == normalized_field_name
            end)

          _ ->
            nil
        end
    end
  end

  defp manifest_field_contract(_field_name), do: nil

  defp graphql_builtin_contract("graphql://contract/common/tenant") do
    %{
      "field" => "common/tenant",
      "summary" =>
        "Tenant headers contract. Provide x-tenant-id, or use x-tenant-code / x-tenant-slug when alias resolver is configured.",
      "doc_url" => "graphql://contract/common/tenant",
      "required_headers" => [],
      "conditional_requirements" => [],
      "body" => """
      # common/tenant

      - Summary: Tenant headers contract. Provide x-tenant-id, or use x-tenant-code / x-tenant-slug when alias resolver is configured.
      - Doc URL: graphql://contract/common/tenant

      ## Required Headers
      - none

      ## Optional Alias Headers
      - x-tenant-code
      - x-tenant-slug

      ## Notes
      - Prefer `x-tenant-id` when the caller already knows the tenant UUID.
      - `x-tenant-code` / `x-tenant-slug` only work when the generated runtime has a tenant alias resolver.
      - Invalid tenant input should surface `invalid_tenant_id` or `tenant_required` with this same `doc_url`.
      """
    }
  end

  defp graphql_builtin_contract(_field_or_doc_url), do: nil

  defp graphql_docs_root do
    manifest_path()
    |> Path.dirname()
    |> Path.join("docs")
  end

  defp graphql_contract_body(doc_url) when is_binary(doc_url) do
    case graphql_builtin_contract(doc_url) do
      %{} = contract ->
        normalize_string(map_get(contract, "body"))

      nil ->
        case graphql_contract_doc_path(doc_url) do
          nil ->
            nil

          path ->
            case File.read(path) do
              {:ok, content} ->
                normalize_string(content)

              _ ->
                nil
            end
        end
    end
  end

  defp graphql_contract_body(_doc_url), do: nil

  defp graphql_contract_doc_path(doc_url) do
    normalized = normalize_string(doc_url)
    prefix = "graphql://contract/"

    if String.starts_with?(normalized, prefix) do
      relative = String.trim_leading(normalized, prefix)
      Path.join(graphql_docs_root(), relative <> ".md")
    else
      nil
    end
  end

  defp graphql_contract_lookup_key(doc_url) when is_binary(doc_url) do
    normalized = normalize_string(doc_url)
    prefix = "graphql://contract/"

    if String.starts_with?(normalized, prefix) do
      normalized
      |> String.trim_leading(prefix)
      |> String.split("/")
      |> List.last()
      |> normalize_string()
    else
      normalized
    end
  end

  defp graphql_contract_lookup_key(value), do: normalize_string(value)

  defp require_actor_for_mutation? do
    Keyword.get(config(), :require_actor_for_mutation, true)
  end

  defp entry_auth_mode(operation) when operation in [:query, :mutation, :subscription] do
    defaults = default_entry_auth_mode(operation)

    config()
    |> Keyword.get(:entry_auth_matrix, [])
    |> Keyword.get(operation, defaults)
    |> normalize_entry_auth_mode(defaults)
  end

  defp entry_auth_mode(_operation), do: :compat

  defp default_entry_auth_mode(:mutation) do
    if require_actor_for_mutation?(), do: :strict, else: :compat
  end

  defp default_entry_auth_mode(:query), do: :compat
  defp default_entry_auth_mode(:subscription), do: :compat
  defp default_entry_auth_mode(_), do: :compat

  defp normalize_entry_auth_mode(mode, _default) when mode in [:strict, :compat], do: mode

  defp normalize_entry_auth_mode(mode, default) when is_binary(mode) do
    case String.downcase(String.trim(mode)) do
      "strict" -> :strict
      "compat" -> :compat
      _ -> default
    end
  end

  defp normalize_entry_auth_mode(mode, _default) when is_boolean(mode) do
    if mode, do: :strict, else: :compat
  end

  defp normalize_entry_auth_mode(_mode, default), do: default

  defp operation_kind(query) when is_binary(query) do
    normalized =
      query
      |> trim_query_prefix()
      |> String.downcase()

    cond do
      String.starts_with?(normalized, "mutation") -> :mutation
      String.starts_with?(normalized, "subscription") -> :subscription
      true -> :query
    end
  end

  defp operation_kind(_), do: :query

  defp trim_query_prefix(query) when is_binary(query) do
    query
    |> String.split("\n")
    |> Enum.drop_while(fn line ->
      trimmed = String.trim(line)
      trimmed == "" or String.starts_with?(trimmed, <<35>>)
    end)
    |> Enum.join("\n")
    |> String.trim_leading()
  end

  defp public_query_whitelisted?(query) when is_binary(query) do
    case query_root_field(query) do
      nil -> false
      field_name -> field_name in public_query_whitelist()
    end
  end

  defp public_query_whitelisted?(_), do: false

  defp public_query_whitelist do
    config()
    |> Keyword.get(:public_query_whitelist, [])
    |> Enum.map(&to_string/1)
  end

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

  defp ensure_tenant_context(context) do
    case resolve_tenant_candidate(context) do
      {:ok, nil} ->
        context

      {:ok, tenant_id} ->
        context
        |> Map.put(:tenant, tenant_id)
        |> Map.put_new(:tenant_id, tenant_id)
        |> Map.delete(:tenant_error)

      {:error, reason, message, metadata} ->
        context
        |> Map.put(
          :tenant_error,
          %{
            "message" => message,
            "code" => "BAD_USER_INPUT",
            "reason" => reason,
            "extensions" => tenant_error_extensions(reason, metadata)
          }
        )
        |> Map.delete(:tenant)
        |> Map.delete(:tenant_id)
    end
  end

  defp resolve_tenant_candidate(context) do
    case existing_tenant_candidate(context) do
      nil -> resolve_conn_tenant_candidate(context)
      candidate -> normalize_tenant_candidate(context, candidate)
    end
  end

  defp existing_tenant_candidate(context) do
    direct_tenant =
      Map.get(context, :tenant) ||
        Map.get(context, "tenant") ||
        Map.get(context, :tenant_id) ||
        Map.get(context, "tenant_id")

    cond do
      not is_nil(direct_tenant) ->
        %{kind: :existing, value: direct_tenant, source: "context"}

      true ->
        case normalize_context_envelope(
               context_value(context, :context_envelope) ||
                 context_value(context, "context_envelope")
             ) do
          nil ->
            nil

          envelope ->
            tenant_scope = envelope |> map_value("scope") |> map_value("tenant")
            correlation_tenant = envelope |> map_value("correlation") |> map_value("tenant")

            cond do
              is_map(tenant_scope) and map_size(tenant_scope) > 0 ->
                %{kind: :existing, value: tenant_scope, source: "scope.tenant"}

              not is_nil(correlation_tenant) ->
                %{kind: :existing, value: correlation_tenant, source: "correlation.tenant"}

              true ->
                nil
            end
        end
    end
  end

  defp resolve_conn_tenant_candidate(context) do
    conn = Map.get(context, :conn) || Map.get(context, "conn")

    case extract_tenant_candidate_from_conn(conn) do
      nil -> {:ok, nil}
      candidate -> normalize_tenant_candidate(context, candidate)
    end
  end

  defp normalize_tenant_candidate(context, %{kind: :existing, value: value}) when is_map(value) do
    normalized = tenant_id_from_map(value)
    if normalized == "", do: {:ok, nil}, else: {:ok, normalized}
  end

  defp normalize_tenant_candidate(context, %{kind: :existing, value: value}) do
    normalized = normalize_string(value)
    if normalized == "", do: {:ok, nil}, else: {:ok, normalized}
  end

  defp normalize_tenant_candidate(context, %{kind: :tenant_id, value: value, source: source}) do
    normalized = normalize_string(value)

    cond do
      normalized == "" ->
        {:ok, nil}

      tenant_id_valid?(normalized) ->
        {:ok, normalized}

      true ->
        {:error, "invalid_tenant_id", invalid_tenant_message(source),
         %{
           "path" => tenant_error_path(source),
           "tenant_source" => source,
           "tenant_value" => normalized
         }}
    end
  end

  defp normalize_tenant_candidate(context, %{kind: kind, value: value, source: source})
       when kind in [:tenant_code, :tenant_slug] do
    normalized = normalize_string(value)

    cond do
      normalized == "" ->
        {:ok, nil}

      true ->
        case resolve_tenant_alias(context, kind, normalized) do
          {:ok, tenant_id} when is_binary(tenant_id) ->
            {:ok, normalize_string(tenant_id)}

          {:ok, %{} = tenant_map} ->
            tenant_id = tenant_id_from_map(tenant_map)

            if tenant_id == "",
              do:
                {:error, "tenant_resolution_failed", tenant_resolution_failed_message(source),
                 %{
                   "path" => tenant_error_path(source),
                   "tenant_source" => source,
                   "tenant_value" => normalized
                 }},
              else: {:ok, tenant_id}

          _ ->
            {:error, "tenant_resolution_failed", tenant_resolution_failed_message(source),
             %{
               "path" => tenant_error_path(source),
               "tenant_source" => source,
               "tenant_value" => normalized
             }}
        end
    end
  end

  defp normalize_tenant_candidate(_context, _candidate), do: {:ok, nil}

  defp resolve_tenant_alias(context, kind, value) do
    hook = Keyword.get(config(), :tenant_resolver, default_tenant_resolver_hook())
    default = default_resolve_tenant_alias(kind, value)

    case apply_optional_hook(hook, [kind, value, context], default) do
      nil -> default
      other -> other
    end
  end

  defp default_tenant_resolver_hook do
    module = HospitalSchedulingWeb.GraphqlHooks

    if function_exported?(module, :resolve_tenant, 3) do
      {module, :resolve_tenant}
    else
      nil
    end
  end

  defp default_resolve_tenant_alias(kind, value) do
    nil
  end

  defp tenant_id_from_map(tenant_map) do
    tenant_id =
      map_value(tenant_map, "id") ||
        map_value(tenant_map, "tenant_id")

    normalize_string(tenant_id)
  end

  defp maybe_put_tenant_id_from_map(context, tenant_map) do
    normalized = tenant_id_from_map(tenant_map)
    if normalized == "", do: context, else: Map.put_new(context, :tenant_id, normalized)
  end

  defp extract_tenant_candidate_from_conn(%Plug.Conn{} = conn) do
    tenant_id = normalize_string(conn.assigns[:tenant_id] || conn.assigns[:tenant])
    tenant_code = normalize_string(List.first(Plug.Conn.get_req_header(conn, "x-tenant-code")))
    tenant_slug = normalize_string(List.first(Plug.Conn.get_req_header(conn, "x-tenant-slug")))
    header_tenant_id = normalize_string(List.first(Plug.Conn.get_req_header(conn, "x-tenant-id")))

    cond do
      tenant_id != "" ->
        %{kind: :existing, value: tenant_id, source: "conn.assigns"}

      tenant_code != "" ->
        %{kind: :tenant_code, value: tenant_code, source: "x-tenant-code"}

      tenant_slug != "" ->
        %{kind: :tenant_slug, value: tenant_slug, source: "x-tenant-slug"}

      header_tenant_id != "" ->
        %{kind: :tenant_id, value: header_tenant_id, source: "x-tenant-id"}

      true ->
        nil
    end
  end

  defp extract_tenant_candidate_from_conn(_), do: nil

  defp tenant_id_valid?(value) do
    format = Keyword.get(config(), :tenant_id_format, :opaque)
    normalized_format = normalize_tenant_id_format(format)

    case normalized_format do
      :uuid -> uuid_like?(value)
      _ -> value != ""
    end
  end

  defp normalize_tenant_id_format(value) when value in [:uuid, :opaque], do: value

  defp normalize_tenant_id_format(value) when is_binary(value) do
    case String.downcase(String.trim(value)) do
      "uuid" -> :uuid
      _ -> :opaque
    end
  end

  defp normalize_tenant_id_format(_), do: :opaque

  defp uuid_like?(value) when is_binary(value) do
    Regex.match?(
      ~r/\A[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}\z/,
      value
    )
  end

  defp uuid_like?(_), do: false

  defp invalid_tenant_message(source) do
    "invalid tenant id from #{source}"
  end

  defp tenant_resolution_failed_message(source) do
    "failed to resolve tenant from #{source}"
  end

  defp tenant_error_path(source) when is_binary(source), do: "headers/" <> source
  defp tenant_error_path(_source), do: "runtime_context/tenant"

  defp tenant_error_extensions(reason, metadata) when is_map(metadata) do
    Map.merge(
      %{"code" => "BAD_USER_INPUT", "reason" => reason},
      Map.merge(
        %{},
        metadata
      )
    )
    |> Map.put_new("hint", tenant_error_hint(reason))
    |> Map.put_new("doc_url", tenant_error_doc_url(reason))
  end

  defp tenant_error_extensions(reason, _metadata) do
    %{"code" => "BAD_USER_INPUT", "reason" => reason}
    |> Map.put_new("hint", tenant_error_hint(reason))
    |> Map.put_new("doc_url", tenant_error_doc_url(reason))
  end

  defp tenant_error_hint("invalid_tenant_id"),
    do: "x-tenant-id 必须是合法 UUID，或改用 x-tenant-code / x-tenant-slug"

  defp tenant_error_hint("tenant_required"),
    do: "请提供 x-tenant-id，或使用 x-tenant-code / x-tenant-slug"

  defp tenant_error_hint("tenant_resolution_failed"),
    do: "请检查 tenant alias 是否存在，或改用 x-tenant-id"

  defp tenant_error_hint(_reason), do: nil

  defp tenant_error_doc_url(reason)
       when reason in ["invalid_tenant_id", "tenant_required", "tenant_resolution_failed"] do
    "graphql://contract/common/tenant"
  end

  defp tenant_error_doc_url(_reason), do: nil

  defp ensure_actor_context(context) do
    actor = ActorContext.from_context(context)

    case actor do
      nil -> context
      value -> Map.put(context, :actor, value)
    end
  end

  defp ensure_correlation_context(context) do
    request_id = request_id_from_context(context)
    trace_id = trace_id_from_context(context)

    context
    |> maybe_put_correlation_value(:request_id, request_id)
    |> maybe_put_correlation_value(:trace_id, trace_id)
  end

  defp maybe_put_correlation_value(context, _key, ""), do: context
  defp maybe_put_correlation_value(context, key, value), do: Map.put_new(context, key, value)

  def actor(context) when is_map(context), do: ActorContext.from_context(context)

  def actor(_), do: nil

  defp actor_present?(context), do: not is_nil(actor(context))

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
