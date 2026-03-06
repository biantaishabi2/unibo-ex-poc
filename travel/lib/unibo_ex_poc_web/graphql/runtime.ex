defmodule UniboExPocWeb.Graphql.Runtime do
  @moduledoc """
  应用侧 GraphQL 运行时桥接（由 UniBO 自动生成）。
  """

  alias Absinthe.Resolution.Helpers
  alias Dataloader.KV
  alias UniboExPocWeb.Graphql.RuntimeConfig

  def new_loader(context \\ %{}) do
    source = RuntimeConfig.source_name()

    Dataloader.new()
    |> Dataloader.add_source(source, KV.new(&RuntimeConfig.load/2, context: context))
  end

  def dataloader(field), do: dataloader(field, [])

  def dataloader(field, opts) do
    source = Keyword.get(opts, :source, RuntimeConfig.source_name())
    Helpers.dataloader(source, field)
  end
end
