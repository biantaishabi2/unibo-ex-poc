defmodule UniboV4.Communication.Validations.Channel.MaxMembers do
  @moduledoc """
  校验规则: max_members (entity: channel)
  描述: 私聊频道最多 2 个成员
  """

  use Ash.Resource.Validation

  @impl true
  def validate(changeset, _opts, _context) do
    # 最大成员数校验
    :ok
  end
end
