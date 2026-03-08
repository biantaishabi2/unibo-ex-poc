defmodule UniboExPoc.ELearning.Changes.SlideProgress.ActionLikeCall7 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(ELearning, :recompute_parent, 2) do
      ELearning.recompute_parent(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: ELearning.recompute_parent/2")
    end
  end
end
