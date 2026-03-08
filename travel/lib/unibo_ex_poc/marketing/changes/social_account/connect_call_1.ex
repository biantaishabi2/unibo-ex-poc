defmodule UniboExPoc.Marketing.Changes.SocialAccount.ConnectCall1 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(Marketing, :oauth_authorize, 2) do
      Marketing.oauth_authorize(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: Marketing.oauth_authorize/2")
    end
  end
end
