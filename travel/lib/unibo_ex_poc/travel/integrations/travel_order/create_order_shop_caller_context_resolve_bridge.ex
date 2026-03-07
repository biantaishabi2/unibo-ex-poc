defmodule UniboExPoc.Travel.Integrations.TravelOrder.CreateOrderShopCallerContextResolveBridge do
  use Ash.Resource.Change

  @provider "shop_caller_context_resolve"
  @action "create_order"
  @declared_errors ["shop_context_not_found", "shop_context_timeout"]
  @request_bindings []
  @response_bindings []

  @impl true
  def change(changeset, _opts, context) do
    request_id = Map.get(context, :request_id) || "travel_order.create_order.shop_caller_context_resolve"
    payload =
      %{
        "entity" => "travel_order",
        "action" => "create_order",
        "integration" => "shop_caller_context_resolve",
        "resource" => inspect(changeset.resource),
        "tenant" => Map.get(context, :tenant) || Map.get(context, :tenant_id),
        "actor" => inspect(Map.get(context, :actor))
      }
      |> Map.merge(resolve_request_payload(changeset, context))

    request = %{
      request_id: request_id,
      provider: @provider,
      action: @action,
      payload: payload,
      declared_errors: @declared_errors
    }

    case UniboExPoc.Travel.Integration.Runtime.dispatch_sync(request) do
      {:ok, response} ->
        apply_response_bindings(changeset, response)
      {:error, error_payload} ->
        code = fetch(error_payload, :code, "integration_dispatch_failed")
        provider_name = fetch(error_payload, :provider, @provider)
        message = fetch(error_payload, :message, "integration dispatch failed")
        Ash.Changeset.add_error(changeset, "[code=#{code}] [provider=#{provider_name}] #{message}")
    end
  end

  defp resolve_request_payload(changeset, context) do
    Enum.reduce(@request_bindings, %{}, fn {from, to}, acc ->
      case resolve_source(changeset, context, from) do
        nil -> acc
        value -> put_payload(acc, String.split(to, ".", trim: true), value)
      end
    end)
  end

  defp apply_response_bindings(changeset, response) do
    payload = extract_response_payload(response)
    Enum.reduce(@response_bindings, changeset, fn {from, target_attr}, acc ->
      case fetch_path(payload, String.split(from, ".", trim: true)) do
        nil -> acc
        value -> Ash.Changeset.force_change_attribute(acc, target_attr, value)
      end
    end)
  end

  defp extract_response_payload(response) when is_map(response) do
    payload = Map.get(response, :payload) || Map.get(response, "payload")
    if is_map(payload), do: payload, else: response
  end
  defp extract_response_payload(_response), do: %{}

  defp resolve_source(changeset, context, source_path) when is_binary(source_path) do
    case String.split(source_path, ".", parts: 2) do
      ["arg", key] -> Ash.Changeset.get_argument(changeset, String.to_atom(key))
      ["attr", key] -> Ash.Changeset.get_attribute(changeset, String.to_atom(key))
      ["attribute", key] -> Ash.Changeset.get_attribute(changeset, String.to_atom(key))
      ["context", key] -> fetch(context, String.to_atom(key), nil)
      ["literal", value] -> value
      _ -> nil
    end
  end
  defp resolve_source(_changeset, _context, _source_path), do: nil

  defp put_payload(map, [], _value), do: map
  defp put_payload(map, [key], value), do: Map.put(map, key, value)
  defp put_payload(map, [key | rest], value) do
    nested = Map.get(map, key)
    nested_map = if is_map(nested), do: nested, else: %{}
    Map.put(map, key, put_payload(nested_map, rest, value))
  end

  defp fetch_path(data, []), do: data
  defp fetch_path(data, [key | rest]) when is_map(data) do
    key_atom = String.to_atom(key)
    value =
      cond do
        Map.has_key?(data, key) -> Map.get(data, key)
        Map.has_key?(data, key_atom) -> Map.get(data, key_atom)
        true -> nil
      end
    fetch_path(value, rest)
  end
  defp fetch_path(_data, _path), do: nil

  defp fetch(map, key, default) when is_map(map) do
    string_key = Atom.to_string(key)
    cond do
      Map.has_key?(map, key) -> Map.get(map, key)
      Map.has_key?(map, string_key) -> Map.get(map, string_key)
      true -> default
    end
  end
  defp fetch(_other, _key, default), do: default
end
