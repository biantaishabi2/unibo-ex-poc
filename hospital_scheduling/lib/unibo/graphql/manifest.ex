defmodule Unibo.Graphql.Manifest do
  @moduledoc """
  GraphQL/前端 manifest 的最小读取器。

  这里不承载页面业务语义，只负责把磁盘上的 JSON 安全读成 map，
  并为 runtime 提供少量通用查找能力。
  """

  def load!(path) when is_binary(path) do
    path
    |> File.read!()
    |> Jason.decode!()
    |> normalize_map()
  end

  def safe_load(path) when is_binary(path) do
    try do
      load!(path)
    rescue
      _ -> %{}
    end
  end

  def field(manifest_data, lookup_key) when is_map(manifest_data) and is_binary(lookup_key) do
    fields = manifest_data |> Map.get("fields", []) |> normalize_list()
    expected = normalize_string(lookup_key)

    Enum.find(fields, fn field ->
      field = normalize_map(field)

      normalize_string(Map.get(field, "field")) == expected or
        normalize_string(Map.get(field, "doc_url")) == expected
    end)
    |> case do
      %{} = field -> field
      _ -> nil
    end
  end

  def field(_manifest_data, _lookup_key), do: nil

  def postprocess_plan_for(_manifest_data, _meta), do: nil
  def frontend_postprocess_plan_for(_manifest_data, _frontend_data, _meta), do: nil

  defp normalize_map(value) when is_map(value) do
    Enum.reduce(value, %{}, fn
      {key, inner}, acc when is_atom(key) -> Map.put(acc, Atom.to_string(key), inner)
      {key, inner}, acc when is_binary(key) -> Map.put(acc, key, inner)
      _, acc -> acc
    end)
  end

  defp normalize_map(_value), do: %{}

  defp normalize_list(value) when is_list(value), do: value
  defp normalize_list(_value), do: []

  defp normalize_string(value) when is_binary(value), do: String.trim(value)
  defp normalize_string(value) when is_atom(value), do: value |> Atom.to_string() |> String.trim()
  defp normalize_string(value) when is_integer(value), do: Integer.to_string(value)
  defp normalize_string(_value), do: ""
end