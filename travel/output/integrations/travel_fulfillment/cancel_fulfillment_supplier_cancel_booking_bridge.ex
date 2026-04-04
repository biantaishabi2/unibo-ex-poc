defmodule Travel.Travel.Integrations.TravelFulfillment.CancelFulfillmentSupplierCancelBookingBridge do
  use Ash.Resource.Change

  @provider "supplier_cancel_booking"
  @queue "travel_supplier_cancel"
  @max_attempts 3
  @idempotency_key_source "arg.order_no"
  @dead_letter_queue nil
  @request_bindings []

  @impl true
  def change(changeset, _opts, context) do
    request_id = resolve_context_path(context, "correlation.request_id") || Map.get(context, :request_id) || "travel_fulfillment.cancel_fulfillment.supplier_cancel_booking"
    dedup_key = resolve_dedup_key(changeset, context, request_id)
    payload =
      %{
        "entity" => "travel_fulfillment",
        "action" => "cancel_fulfillment",
        "integration" => "supplier_cancel_booking",
        "provider" => @provider,
        "integration_mode" => "async",
        "request_id" => request_id,
        "queue" => @queue,
        "dead_letter_queue" => @dead_letter_queue,
        "max_attempts" => @max_attempts,
        "idempotency_key_source" => @idempotency_key_source,
        "resource" => inspect(changeset.resource),
        "tenant" => resolve_context_path(context, "scope.tenant.id") || Map.get(context, :tenant) || Map.get(context, :tenant_id),
        "actor" => inspect(Map.get(context, :actor) || resolve_context_path(context, "principal"))
      }
      |> Map.merge(resolve_request_payload(changeset, context))

    task = %{kind: "integration_async_dispatch", dedup_key: dedup_key, payload: payload, max_attempts: @max_attempts}
    if Code.ensure_loaded?(Travel.AsyncRuntime.Queue) and function_exported?(Travel.AsyncRuntime.Queue, :enqueue, 1) do
      case Travel.AsyncRuntime.Queue.enqueue(task) do
        {:ok, :duplicate} -> changeset
        {:ok, _task} -> changeset
        {:error, reason} -> Ash.Changeset.add_error(changeset, "async integration enqueue failed: #{inspect(reason)}")
      end
    else
      Ash.Changeset.add_error(changeset, "async runtime queue unavailable")
    end
  end

  defp resolve_dedup_key(changeset, context, request_id) do
    source = @idempotency_key_source
    raw_key = if is_binary(source) and source != "", do: resolve_source(changeset, context, source), else: nil
    key = if raw_key in [nil, ""], do: request_id, else: to_string(raw_key)
    "integration:travel_fulfillment:cancel_fulfillment:supplier_cancel_booking:" <> key
  end

  defp resolve_request_payload(changeset, context) do
    Enum.reduce(@request_bindings, %{}, fn {from, to}, acc ->
      case resolve_source(changeset, context, from) do
        nil -> acc
        value -> put_payload(acc, String.split(to, ".", trim: true), value)
      end
    end)
  end

  defp resolve_source(changeset, context, source_path) when is_binary(source_path) do
    case String.split(source_path, ".", parts: 2) do
      ["arg", key] -> Ash.Changeset.get_argument(changeset, String.to_atom(key))
      ["attr", key] -> Ash.Changeset.get_attribute(changeset, String.to_atom(key))
      ["attribute", key] -> Ash.Changeset.get_attribute(changeset, String.to_atom(key))
      ["calc", key] -> resolve_calculation(changeset, key)
      ["calculation", key] -> resolve_calculation(changeset, key)
      ["context", key] -> resolve_context_path(context, key)
      ["literal", value] -> value
      _ -> nil
    end
  end
  defp resolve_source(_changeset, _context, _source_path), do: nil

  defp resolve_calculation(_changeset, _key), do: nil

  defp resolve_context_path(context, key_path) when is_map(context) and is_binary(key_path) do
    keys = String.split(key_path, ".", trim: true)
    fetch_path(context, keys)
  end
  defp resolve_context_path(_context, _key_path), do: nil

  defp put_payload(map, [], _value), do: map
  defp put_payload(map, [key], value), do: Map.put(map, key, value)
  defp put_payload(map, [key | rest], value) do
    nested = Map.get(map, key)
    nested_map = if is_map(nested), do: nested, else: %{}
    Map.put(map, key, put_payload(nested_map, rest, value))
  end

  defp fetch_path(data, []), do: data
  defp fetch_path(data, [key | rest]) when is_map(data) do
    lookup_map = normalize_lookup_map(data)
    value =
      cond do
        Map.has_key?(lookup_map, key) -> Map.get(lookup_map, key)
        true -> case Enum.reduce_while(lookup_map, :not_found, fn {existing_key, existing_value}, _acc -> if to_string(existing_key) == key, do: {:halt, {:found, existing_value}}, else: {:cont, :not_found} end) do {:found, resolved} -> resolved; _ -> nil end
      end
    fetch_path(value, rest)
  end
  defp fetch_path(_data, _path), do: nil
  defp normalize_lookup_map(data) when is_struct(data), do: Map.from_struct(data)
  defp normalize_lookup_map(data) when is_map(data), do: data
  defp normalize_lookup_map(_data), do: %{}
end
