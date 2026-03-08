defmodule UniboV4.Marketing.Changes.Mailing.LaunchCall5 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(Marketing, :exclude_opted_out_and_blacklisted, 2) do
      Marketing.exclude_opted_out_and_blacklisted(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: Marketing.exclude_opted_out_and_blacklisted/2")
    end
  end
end
