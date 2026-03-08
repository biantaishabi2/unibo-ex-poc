defmodule UniboExPoc.Marketing.Changes.SocialAccount.RefreshTokenCall5 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(Marketing, :platform_oauth_refresh, 2) do
      Marketing.platform_oauth_refresh(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: Marketing.platform_oauth_refresh/2")
    end
  end
end
