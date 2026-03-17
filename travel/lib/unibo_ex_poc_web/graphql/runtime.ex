defmodule UniboExPocWeb.Graphql.Runtime do
  @moduledoc """
  应用侧 GraphQL 运行时桥接（由 UniBO 自动生成）。
  """

  alias Unibo.Graphql.Runtime, as: CoreRuntime
  alias UniboExPocWeb.Graphql.RuntimeConfig

  def new_loader(context \\ %{}), do: CoreRuntime.new_loader(RuntimeConfig, context)

  def dataloader(field), do: dataloader(field, [])

  def dataloader(field, opts), do: CoreRuntime.dataloader(RuntimeConfig, field, opts)
end
