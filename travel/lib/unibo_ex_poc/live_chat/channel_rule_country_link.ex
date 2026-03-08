defmodule UniboExPoc.LiveChat.ChannelRuleCountryLink do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.LiveChat,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "规则与国家关联桥接"
  end

  postgres do
    table "live_chat_channel_rule_country_links"
    repo UniboExPoc.Repo
  end

  graphql do
    type :live_chat_channel_rule_country_link

    queries do
      get :get_live_chat_channel_rule_country_link, :read
      list :list_live_chat_channel_rule_country_links, :read
    end

  end

  attributes do
    uuid_primary_key :id
  end

  relationships do
    belongs_to :channel_rule, UniboExPoc.LiveChat.ChannelRule do
      public? true
      allow_nil? false
    end
    belongs_to :country, UniboExPoc.LiveChat.Country do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read, :update]
  end

end
