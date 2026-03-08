defmodule UniboExPoc.Quality.Changes.QualityAlert.StartProgressCall8 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(quality, :schedule_capa_reminder, 2) do
      quality.schedule_capa_reminder(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: quality.schedule_capa_reminder/2")
    end
  end
end
