defmodule HospitalSchedulingWeb.Graphql.MetaMapper do
  @moduledoc """
  元信息到 GraphQL 字段映射辅助（由 UniBO 自动生成）。
  """

  def to_field_name(meta) when is_atom(meta), do: meta
  def to_field_name(meta) when is_binary(meta), do: String.to_atom(meta)
end
