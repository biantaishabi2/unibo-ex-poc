defmodule UniboExPoc.Marketing.Changes.EventLeadRule.RunOnRegistrationsCall1 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(Marketing, :trigger_lead_generation, 2) do
      Marketing.trigger_lead_generation(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: Marketing.trigger_lead_generation/2")
    end
  end
end
