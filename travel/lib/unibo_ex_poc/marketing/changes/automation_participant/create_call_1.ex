defmodule UniboExPoc.Marketing.Changes.AutomationParticipant.CreateCall1 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(Marketing, :create_root_traces, 2) do
      Marketing.create_root_traces(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: Marketing.create_root_traces/2")
    end
  end
end
