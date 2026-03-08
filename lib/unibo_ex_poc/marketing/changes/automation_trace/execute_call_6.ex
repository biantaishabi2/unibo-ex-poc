defmodule UniboV4.Marketing.Changes.AutomationTrace.ExecuteCall6 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(Marketing, :cancel_mutual_exclusive_branch, 2) do
      Marketing.cancel_mutual_exclusive_branch(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: Marketing.cancel_mutual_exclusive_branch/2")
    end
  end
end
