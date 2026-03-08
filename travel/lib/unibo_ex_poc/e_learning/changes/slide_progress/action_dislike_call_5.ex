defmodule UniboExPoc.ELearning.Changes.SlideProgress.ActionDislikeCall5 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(ELearning, :toggle_vote, 2) do
      ELearning.toggle_vote(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: ELearning.toggle_vote/2")
    end
  end
end
