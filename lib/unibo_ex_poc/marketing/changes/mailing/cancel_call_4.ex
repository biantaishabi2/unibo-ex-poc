defmodule UniboV4.Marketing.Changes.Mailing.CancelCall4 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(Marketing, :clear_schedule_date, 2) do
      Marketing.clear_schedule_date(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: Marketing.clear_schedule_date/2")
    end
  end
end
