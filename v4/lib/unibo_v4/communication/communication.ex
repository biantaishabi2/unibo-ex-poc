defmodule UniboV4.Communication do
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
    resource UniboV4.Communication.Message
    resource UniboV4.Communication.Channel
    resource UniboV4.Communication.ChannelMember
  end
end
