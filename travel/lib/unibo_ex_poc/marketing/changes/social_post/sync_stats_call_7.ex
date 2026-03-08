defmodule UniboExPoc.Marketing.Changes.SocialPost.SyncStatsCall7 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(Marketing, :fetch_platform_stats, 2) do
      Marketing.fetch_platform_stats(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: Marketing.fetch_platform_stats/2")
    end
  end
end
