defmodule UniboExPoc.Travel.Integration.Runtime do
  @moduledoc false

  @error_code_provider_not_found "provider_not_found"
  @error_code_declared_error "integration_declared_error"
  @otp_app :travel

  def dispatch_sync(request) when is_map(request) do
    provider = normalize_text(fetch(request, :provider, ""))
    action = normalize_text(fetch(request, :action, ""))
    request_id = normalize_text(fetch(request, :request_id, "integration.request"))
    payload = normalize_payload(fetch(request, :payload, %{}))
    declared_errors = normalize_declared_errors(fetch(request, :declared_errors, []))

    case resolve_provider_handler(provider) do
      nil ->
        {:error, provider_not_found(provider, action, request_id)}
      handler ->
        adapter_request = %{
          "request_id" => request_id,
          "action" => action,
          "payload" => payload
        }

        case handler.(adapter_request) do
          {:ok, response} ->
            {:ok, normalize_success(response, provider, action, request_id)}
          {:error, error_payload} ->
            {:error, normalize_error(error_payload, provider, action, request_id, declared_errors)}
          other ->
            {:error, normalize_error(%{code: @error_code_declared_error, message: "invalid adapter result: #{inspect(other)}"}, provider, action, request_id, declared_errors)}
        end
    end
  end
  def dispatch_sync(_request), do: {:error, provider_not_found("", "", "integration.request")}

  defp resolve_provider_handler(provider) do
    configured_provider_handler(provider) || resolve_builtin_provider_handler(provider)
  end

  defp configured_provider_handler(provider) do
    dispatch = Application.get_env(@otp_app, :integration_adapter_dispatch)
    providers = Application.get_env(@otp_app, :integration_providers, %{})

    cond do
      is_function(dispatch, 2) ->
        fn req -> dispatch.(provider, req) end
      is_map(providers) ->
        candidate = Map.get(providers, provider) || Map.get(providers, String.to_atom(provider))
        if is_function(candidate, 1), do: candidate, else: nil
      true ->
        nil
    end
  rescue
    ArgumentError -> nil
  end

  defp resolve_builtin_provider_handler(provider) do
    case provider do
      "shop_caller_context_resolve" -> fn req -> dispatch_builtin_provider("shop_caller_context_resolve", req) end
      "shop_eligibility_quote" -> fn req -> dispatch_builtin_provider("shop_eligibility_quote", req) end
      "payment_capture" -> fn req -> dispatch_builtin_provider("payment_capture", req) end
      "create_approval_instance" -> fn req -> dispatch_builtin_provider("create_approval_instance", req) end
      "supplier_confirm_booking" -> fn req -> dispatch_builtin_provider("supplier_confirm_booking", req) end
      "supplier_issue_document" -> fn req -> dispatch_builtin_provider("supplier_issue_document", req) end
      _ -> nil
    end
  end

  defp dispatch_builtin_provider(provider, request) when is_map(request) do
    request_id = normalize_text(fetch(request, :request_id, "integration.request"))
    action = normalize_text(fetch(request, :action, ""))
    payload = normalize_payload(fetch(request, :payload, %{}))
    forced_code = normalize_text(fetch(payload, :force_error_code, ""))
    if forced_code != "" do
      {:error, %{
        "code" => forced_code,
        "message" => "mocked integration error: #{forced_code}",
        "audit" => normalize_audit(%{}, request_id, provider, action, "error", forced_code),
        "retry_hint" => %{"retryable" => false, "after_ms" => nil, "reason" => nil}
      }}
    else
      {:ok, %{
        payload: builtin_mock_payload(provider, action, request_id, payload),
        audit: normalize_audit(%{}, request_id, provider, action, "success", "integration_mock_success")
      }}
    end
  end

  defp builtin_mock_payload("shop_caller_context_resolve", "create", request_id, payload) do
    %{
      "current_shop_id" => fetch(payload, :current_shop_id, fetch(payload, :shop_id, fetch(payload, :host_shop_id, mock_uuid(request_id, "shop_caller_context_resolve", "create", "current_shop_id")))),
      "member_id" => fetch(payload, :member_id, "mock_member_id"),
      "enterprise_id" => fetch(payload, :enterprise_id, fetch(payload, :tenant_id, "mock_enterprise_id"))
    }
  end

  defp builtin_mock_payload("shop_eligibility_quote", "confirm_quote", request_id, payload) do
    %{
      "allowed" => true,
      "reason" => "mock_shop_eligibility_quote_confirm_quote_reason",
      "product_type" => fetch(payload, :product_type, "mock_product_type"),
      "travel_enabled" => true,
      "points_enabled" => true,
      "mixed_payment_allowed" => true,
      "cash_payment_enabled" => true,
      "available_points" => 0,
      "points_requested" => fetch(payload, :points_requested, 0),
      "points_sufficient" => true,
      "points_deduction_amount" => fetch(payload, :points_deduction_amount, 0),
      "payable_amount" => fetch(payload, :payable_amount, fetch(payload, :amount, 0)),
      "recommended_payment_method" => "cash",
      "member_id" => fetch(payload, :member_id, "mock_member_id"),
      "shop_id" => fetch(payload, :current_shop_id, fetch(payload, :shop_id, fetch(payload, :host_shop_id, mock_uuid(request_id, "shop_eligibility_quote", "confirm_quote", "shop_id")))),
      "amount" => fetch(payload, :amount, fetch(payload, :total_amount, 0))
    }
  end

  defp builtin_mock_payload("payment_capture", "submit_order", request_id, payload) do
    %{
      "status" => "approved",
      "method" => fetch(payload, :payment_method, "cash"),
      "external_ref" => fetch(payload, :external_ref, request_id),
      "points_used" => fetch(payload, :points_used, 0),
      "points_deduction_amount" => fetch(payload, :points_deduction_amount, 0),
      "cash_amount" => fetch(payload, :cash_amount, 0),
      "reason" => "mock_payment_capture_submit_order_reason"
    }
  end

  defp builtin_mock_payload("payment_capture", "submit_waitlist", request_id, payload) do
    %{
      "status" => "approved",
      "method" => fetch(payload, :payment_method, "cash"),
      "external_ref" => fetch(payload, :external_ref, request_id),
      "points_used" => fetch(payload, :points_used, 0),
      "points_deduction_amount" => fetch(payload, :points_deduction_amount, 0),
      "cash_amount" => fetch(payload, :cash_amount, 0),
      "reason" => "mock_payment_capture_submit_waitlist_reason"
    }
  end

  defp builtin_mock_payload("create_approval_instance", "request_cancel", request_id, payload) do
    %{
      "instance_id" => mock_uuid(request_id, "create_approval_instance", "request_cancel", "instance_id"),
      "status" => "mock_create_approval_instance_request_cancel_status"
    }
  end

  defp builtin_mock_payload("supplier_confirm_booking", "confirm_booking", request_id, payload) do
    %{
      "confirm_status" => "mock_supplier_confirm_booking_confirm_booking_confirm_status",
      "supplier_booking_ref" => "mock_supplier_confirm_booking_confirm_booking_supplier_booking_ref",
      "confirmation_payload" => "mock_supplier_confirm_booking_confirm_booking_confirmation_payload"
    }
  end

  defp builtin_mock_payload("supplier_issue_document", "issue_voucher_or_ticket", request_id, payload) do
    %{
      "issue_status" => "mock_supplier_issue_document_issue_voucher_or_ticket_issue_status",
      "voucher_or_ticket_ref" => "mock_supplier_issue_document_issue_voucher_or_ticket_voucher_or_ticket_ref",
      "ticket_refs" => %{}
    }
  end

  defp builtin_mock_payload("create_approval_instance", "submit", request_id, payload) do
    %{
      "instance_id" => mock_uuid(request_id, "create_approval_instance", "submit", "instance_id"),
      "status" => "mock_create_approval_instance_submit_status"
    }
  end

  defp builtin_mock_payload(_provider, _action, request_id, _payload), do: %{"request_id" => request_id}

  defp normalize_success(response, provider, action, request_id) do
    response_map = normalize_map(response)
    audit =
      response_map
      |> fetch(:audit, %{})
      |> normalize_audit(request_id, provider, action, "success", fetch(response_map, :code, "integration_success"))
    %{
      "request_id" => request_id,
      "provider" => provider,
      "action" => action,
      "payload" => normalize_payload(fetch(response_map, :payload, %{})),
      "audit" => audit,
      "retry_hint" => fetch(response_map, :retry_hint, nil)
    }
  end

  defp normalize_error(error_payload, provider, action, request_id, declared_errors) do
    error_map = normalize_map(error_payload)
    raw_code = normalize_text(fetch(error_map, :code, @error_code_declared_error))

    code =
      cond do
        raw_code == @error_code_provider_not_found ->
          @error_code_provider_not_found
        Enum.empty?(declared_errors) ->
          raw_code
        raw_code in declared_errors ->
          raw_code
        true ->
          @error_code_declared_error
      end

    message =
      cond do
        code == @error_code_provider_not_found ->
          fetch(error_map, :message, "provider `#{provider}` is not registered")
        code == @error_code_declared_error and raw_code != code ->
          "integration error code `#{raw_code}` is not declared"
        true ->
          fetch(error_map, :message, "integration dispatch failed")
      end

    audit =
      error_map
      |> fetch(:audit, %{})
      |> normalize_audit(request_id, provider, action, "error", code)

    %{
      "code" => code,
      "provider" => provider,
      "action" => action,
      "message" => message,
      "audit" => audit,
      "retry_hint" => fetch(error_map, :retry_hint, nil)
    }
  end

  defp provider_not_found(provider, action, request_id) do
    %{
      "code" => @error_code_provider_not_found,
      "provider" => provider,
      "action" => action,
      "message" => "provider `#{provider}` is not registered",
      "audit" => normalize_audit(%{}, request_id, provider, action, "error", @error_code_provider_not_found),
      "retry_hint" => %{"retryable" => false, "after_ms" => nil, "reason" => nil}
    }
  end

  defp normalize_audit(value, request_id, provider, action, outcome, code) do
    audit = normalize_map(value)
    %{
      "request_id" => fetch(audit, :request_id, request_id),
      "provider" => fetch(audit, :provider, provider),
      "action" => fetch(audit, :action, action),
      "outcome" => fetch(audit, :outcome, outcome),
      "code" => fetch(audit, :code, code)
    }
  end

  defp normalize_map(value) when is_map(value), do: value
  defp normalize_map(_value), do: %{}
  defp normalize_payload(value) when is_map(value), do: value
  defp normalize_payload(_value), do: %{}

  defp normalize_declared_errors(values) when is_list(values) do
    values
    |> Enum.map(&normalize_text/1)
    |> Enum.reject(&(&1 == ""))
    |> Enum.uniq()
  end
  defp normalize_declared_errors(_values), do: []

  defp normalize_text(value) when is_binary(value), do: String.trim(value)
  defp normalize_text(value) when is_atom(value), do: value |> Atom.to_string() |> String.trim()
  defp normalize_text(value), do: value |> to_string() |> String.trim()

  defp mock_uuid(request_id, provider, action, field) do
    seed = Enum.join([request_id, provider, action, field], ":")
    hex = :crypto.hash(:md5, seed) |> Base.encode16(case: :lower)
    <<a::binary-size(8), b::binary-size(4), c::binary-size(4), d::binary-size(4), e::binary-size(12)>> = hex
    Enum.join([a, b, c, d, e], "-")
  end

  defp fetch(map, key, default) when is_map(map) do
    Map.get(map, key) || Map.get(map, Atom.to_string(key)) || default
  end
  defp fetch(_value, _key, default), do: default
end
