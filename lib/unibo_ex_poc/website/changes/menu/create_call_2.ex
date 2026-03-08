defmodule UniboV4.Website.Changes.Menu.CreateCall2 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(Website, :auto_copy_to_all_websites, 2) do
      Website.auto_copy_to_all_websites(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: Website.auto_copy_to_all_websites/2")
    end
  end
end
