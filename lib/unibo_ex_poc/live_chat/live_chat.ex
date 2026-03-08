defmodule UniboV4.LiveChat do
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
    resource UniboV4.LiveChat.LiveChatChannel
    resource UniboV4.LiveChat.LiveChatChannel.Version
    resource UniboV4.LiveChat.ChannelRule
    resource UniboV4.LiveChat.ChannelRule.Version
    resource UniboV4.LiveChat.ChatSession
    resource UniboV4.LiveChat.ChatSession.Version
    resource UniboV4.LiveChat.LiveChatChannelUserLink
    resource UniboV4.LiveChat.ChannelRuleCountryLink
    resource UniboV4.LiveChat.Country
    resource UniboV4.LiveChat.ChatbotScript
    resource UniboV4.LiveChat.ChatbotScriptStep
    resource UniboV4.LiveChat.Party
  end
end
