defmodule UniboExPoc.LiveChat do
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
    resource UniboExPoc.LiveChat.LiveChatChannel
    resource UniboExPoc.LiveChat.LiveChatChannel.Version
    resource UniboExPoc.LiveChat.ChannelRule
    resource UniboExPoc.LiveChat.ChannelRule.Version
    resource UniboExPoc.LiveChat.ChatSession
    resource UniboExPoc.LiveChat.ChatSession.Version
    resource UniboExPoc.LiveChat.LiveChatChannelUserLink
    resource UniboExPoc.LiveChat.ChannelRuleCountryLink
    resource UniboExPoc.LiveChat.Country
    resource UniboExPoc.LiveChat.ChatbotScript
    resource UniboExPoc.LiveChat.ChatbotScriptStep
    resource UniboExPoc.LiveChat.Party
  end
end
