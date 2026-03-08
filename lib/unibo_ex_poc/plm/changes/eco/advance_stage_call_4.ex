defmodule UniboV4.PLM.Changes.Eco.AdvanceStageCall4 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(PLM, :create_approvals_from_template, 2) do
      PLM.create_approvals_from_template(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: PLM.create_approvals_from_template/2")
    end
  end
end
