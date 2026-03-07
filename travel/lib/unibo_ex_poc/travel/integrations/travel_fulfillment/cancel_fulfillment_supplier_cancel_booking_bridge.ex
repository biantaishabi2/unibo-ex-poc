defmodule UniboExPoc.Travel.Integrations.TravelFulfillment.CancelFulfillmentSupplierCancelBookingBridge do
  use Ash.Resource.Change

  @provider "supplier_cancel_booking"
  @action "cancel_fulfillment"
  @queue "travel_supplier_cancel"
  @max_attempts 3
  @idempotency_key_source "context.request_id"
  @dead_letter_queue nil
  @request_bindings []

  @impl true
  def change(changeset, _opts, context) do
    request_id = Map.get(context, :request_id) || "travel_fulfillment.cancel_fulfillment.supplier_cancel_booking"
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
        "tenant" => Map.get(context, :tenant) || Map.get(context, :tenant_id),
        "actor" => inspect(Map.get(context, :actor))
      }
      |> Map.merge(resolve_request_payload(changeset, context))

    task = %{kind: "integration_async_dispatch", dedup_key: dedup_key, payload: payload, max_attempts: @max_attempts}
    if Code.ensure_loaded?(UniboExPoc.Travel.AsyncRuntime.Queue) and function_exported?(UniboExPoc.Travel.AsyncRuntime.Queue, :enqueue, 1) do
      case UniboExPoc.Travel.AsyncRuntime.Queue.enqueue(task) do
        {:ok, _task} -> changeset
        {:ok, :duplicate} -> changeset
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
