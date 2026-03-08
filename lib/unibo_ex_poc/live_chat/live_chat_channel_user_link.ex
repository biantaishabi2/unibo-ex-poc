defmodule UniboV4.LiveChat.LiveChatChannelUserLink do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.LiveChat,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "客服频道与操作员关联桥接"
  end

  postgres do
    table "live_chat_channel_user_links"
    repo UniboV4.Repo
  end

  graphql do
    type :live_chat_live_chat_channel_user_link

    queries do
      get :get_live_chat_live_chat_channel_user_link, :read
      list :list_live_chat_live_chat_channel_user_links, :read
    end

  end

  attributes do
    uuid_primary_key :id
  end

  relationships do
    belongs_to :livechat_channel, UniboV4.LiveChat.LiveChatChannel do
      public? true
      allow_nil? false
    end
    belongs_to :user, UniboV4.LiveChat.Party do
      public? true
      allow_nil? false
      source_attribute :user_party_id
    end
  end

  actions do
    defaults [:read, :update]
  end

end
