defmodule Unibo.Graphql.Manifest do
  @moduledoc """
  运行时 manifest 读取辅助。

  这里先提供最小实现，保证 hospital_scheduling 能读取
  `priv/unibo/graphql/manifest.json` 与 `priv/unibo/frontend_manifest.v1.json`。
  """

  def load!(path) do
    path
    |> File.read!()
    |> Jason.decode!()
  end

  def safe_load(path) do
    try do
      load!(path)
    rescue
      _ -> %{}
    end
  end

  def fields(manifest), do: Map.get(manifest, "fields", [])

  def fields(manifest, kind) when is_atom(kind) do
    kind_str = Atom.to_string(kind)
    Enum.filter(fields(manifest), &(&1["kind"] == kind_str))
  end
end

