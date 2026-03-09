defmodule UniboExPoc.Expenses.Integration.Runtime do
  @moduledoc false

  @error_code_provider_not_found "provider_not_found"
  @error_code_declared_error "integration_declared_error"
  @otp_app :unibo_ex_poc

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

  defp fetch(map, key, default) when is_map(map) do
    Map.get(map, key) || Map.get(map, Atom.to_string(key)) || default
  end
  defp fetch(_value, _key, default), do: default
end
