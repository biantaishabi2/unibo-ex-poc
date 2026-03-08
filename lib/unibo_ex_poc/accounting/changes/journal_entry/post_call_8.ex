defmodule UniboV4.Accounting.Changes.JournalEntry.PostCall8 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(Accounting, :assign_sequence_number, 2) do
      Accounting.assign_sequence_number(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: Accounting.assign_sequence_number/2")
    end
  end
end
