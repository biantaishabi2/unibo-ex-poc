# Workflow: channel_rule_maintain_flow — 频道规则维护流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> destroy
#   update --> destroy
#   destroy --> [*]
# ```
defmodule UniboV4.LiveChat.ChannelRule do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.LiveChat,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "live_chat_channel_rules"
    repo UniboV4.Repo
  end

  graphql do
    type :live_chat_channel_rule

    queries do
      get :get_live_chat_channel_rule, :read
      list :list_live_chat_channel_rules, :read
      get :get_match_rule_live_chat_channel_rule, :match_rule
      list :list_match_rule_live_chat_channel_rules, :match_rule
    end

    mutations do
      create :create_live_chat_channel_rule, :create
      update :update_live_chat_channel_rule, :update
      destroy :delete_live_chat_channel_rule, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :regex_url, :string, public?: true
    attribute :action, :atom do
      constraints one_of: [:display_button, :display_button_and_text, :auto_popup, :hide_button]
      public? true
    end
    attribute :auto_popup_timer, :integer, public?: true
    attribute :sequence, :integer do
      default 10
      public? true
    end
    attribute :chatbot_only_if_no_operator, :boolean do
      default false
      public? true
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :channel, UniboV4.LiveChat.LiveChatChannel do
      public? true
      allow_nil? false
    end
    many_to_many :country_ids, UniboV4.LiveChat.Country do
      public? true
      through UniboV4.LiveChat.ChannelRuleCountryLink
    end
    belongs_to :chatbot_script_id, UniboV4.LiveChat.ChatbotScript do
      public? true
    end
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:regex_url, :action, :auto_popup_timer, :sequence, :chatbot_only_if_no_operator]
      argument :channel_id, :uuid, allow_nil?: false
      change manage_relationship(:channel_id, :channel, type: :append, on_lookup: :relate)
      validate present(:action)
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
    end
    update :update do
      primary? true
      accept [:regex_url, :action, :auto_popup_timer, :sequence, :chatbot_only_if_no_operator]
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
      require_atomic? false
    end
    read :match_rule do
      argument :channel_id, :uuid, allow_nil?: false
      argument :url, :string, allow_nil?: false
      argument :country_id, :uuid
    end
  end

end
