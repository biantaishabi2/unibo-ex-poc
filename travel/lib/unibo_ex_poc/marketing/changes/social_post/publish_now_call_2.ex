defmodule UniboExPoc.Marketing.Changes.SocialPost.PublishNowCall2 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(Marketing, :fan_out_to_platforms, 2) do
      Marketing.fan_out_to_platforms(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: Marketing.fan_out_to_platforms/2")
    end
  end
end
