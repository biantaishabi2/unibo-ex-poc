defmodule UniboV4.Website.Changes.WebSite.CreateCall4 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(Website, :format_domain, 2) do
      Website.format_domain(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: Website.format_domain/2")
    end
  end
end
