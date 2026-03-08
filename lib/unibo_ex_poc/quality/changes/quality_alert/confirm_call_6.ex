defmodule UniboV4.Quality.Changes.QualityAlert.ConfirmCall6 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(quality, :notify_team, 2) do
      quality.notify_team(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: quality.notify_team/2")
    end
  end
end
