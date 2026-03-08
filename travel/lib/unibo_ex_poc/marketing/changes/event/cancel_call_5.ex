defmodule UniboExPoc.Marketing.Changes.Event.CancelCall5 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(Marketing, :template_defaults_sync, 2) do
      Marketing.template_defaults_sync(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: Marketing.template_defaults_sync/2")
    end
  end
end
