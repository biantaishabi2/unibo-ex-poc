defmodule UniboV4.HR.Changes.Training.CompleteCall4 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(HR, :custom, 2) do
      HR.custom(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: HR.custom/2")
    end
  end
end
