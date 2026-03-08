defmodule UniboV4.Analytic.Changes.AnalyticDistribution.UpdateCall1 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(Analytic, :regenerate_analytic_lines, 2) do
      Analytic.regenerate_analytic_lines(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: Analytic.regenerate_analytic_lines/2")
    end
  end
end
