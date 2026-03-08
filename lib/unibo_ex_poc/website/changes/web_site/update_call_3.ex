defmodule UniboV4.Website.Changes.WebSite.UpdateCall3 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(Website, :auto_create_cookie_policy_page, 2) do
      Website.auto_create_cookie_policy_page(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: Website.auto_create_cookie_policy_page/2")
    end
  end
end
