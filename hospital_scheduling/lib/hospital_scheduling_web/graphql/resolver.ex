defmodule HospitalSchedulingWeb.Graphql.Resolver do
  @moduledoc """
  应用侧 Resolver 桥接（由 UniBO 自动生成）。
  """

  alias Unibo.Graphql.Resolver, as: CoreResolver
  alias HospitalSchedulingWeb.Graphql.RuntimeConfig

  def resolve_with(meta, parent, args, resolution),
    do: CoreResolver.resolve_with(RuntimeConfig, meta, parent, args, resolution)
end
