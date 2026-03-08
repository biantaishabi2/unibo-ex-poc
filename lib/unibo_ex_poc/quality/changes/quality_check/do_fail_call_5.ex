defmodule UniboV4.Quality.Changes.QualityCheck.DoFailCall5 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(quality, :block_ref_document, 2) do
      quality.block_ref_document(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: quality.block_ref_document/2")
    end
  end
end
