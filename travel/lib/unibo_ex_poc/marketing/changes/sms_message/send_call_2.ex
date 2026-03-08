defmodule UniboExPoc.Marketing.Changes.SmsMessage.SendCall2 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(Marketing, :call_iap_provider, 2) do
      Marketing.call_iap_provider(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: Marketing.call_iap_provider/2")
    end
  end
end
