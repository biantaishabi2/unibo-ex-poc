defmodule UniboV4.Marketing.Changes.Segment.RefreshCountCall1 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(Marketing, :recompute_member_count, 2) do
      Marketing.recompute_member_count(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: Marketing.recompute_member_count/2")
    end
  end
end
