defmodule UniboExPoc.Manufacturing.Changes.WorkOrder.FinishCall6 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(Manufacturing, :close_productivity_record, 2) do
      Manufacturing.close_productivity_record(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: Manufacturing.close_productivity_record/2")
    end
  end
end
