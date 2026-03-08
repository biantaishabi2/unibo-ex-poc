defmodule UniboExPoc.Blog.Calculations.BlogPost.PostDate do
  @moduledoc """
  Calculation 模块: :post_date (type: :utc_datetime, entity: blog_post)
  原始 expr: op: coalesce args: - op: ref   args:   - published_date - op: ref   args:   - inserted_at
  """

  use Ash.Resource.Calculation

  @impl true
  def calculate(records, _opts, _context) do
    # TODO: 实现 :post_date 的计算逻辑
    {:ok, Enum.map(records, fn _record -> nil end)}
  end
end
