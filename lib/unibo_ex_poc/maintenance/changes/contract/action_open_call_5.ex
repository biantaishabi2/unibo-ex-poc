defmodule UniboV4.Maintenance.Changes.Contract.ActionOpenCall5 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(Maintenance, :auto_state_transition, 2) do
      Maintenance.auto_state_transition(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: Maintenance.auto_state_transition/2")
    end
  end
end
