defmodule UniboV4.LiveChat.ChannelRuleCountryLink do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.LiveChat,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "live_chat_channel_rule_country_links"
    repo UniboV4.Repo
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
    belongs_to :channel_rule, UniboV4.LiveChat.ChannelRule do
      public? true
      allow_nil? false
    end
    belongs_to :country, UniboV4.LiveChat.Country do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read, :update]
  end

end
