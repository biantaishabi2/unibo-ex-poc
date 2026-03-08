defmodule UniboV4.Communication.Validations.Channel.DisableMessageSubscribe do
  @moduledoc """
  校验规则: disable_message_subscribe (entity: channel)
  """

  use Ash.Resource.Validation

  @impl true
  def validate(changeset, _opts, _context) do
    # TODO: 实现业务规则 disable_message_subscribe
    :ok
  end
end
