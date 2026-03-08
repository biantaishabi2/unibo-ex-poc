defmodule UniboExPoc.Quality.Changes.QualityCheck.DoFailCall6 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(quality, :create_quality_alert, 2) do
      quality.create_quality_alert(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: quality.create_quality_alert/2")
    end
  end
end
