# Workflow: channel_rule_maintain_flow — 频道规则维护流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> destroy
#   update --> destroy
#   destroy --> [*]
# ```
defmodule UniboExPoc.LiveChat.ChannelRule do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.LiveChat,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "频道显示规则，通过 URL 正则与国家条件控制聊天按钮行为"
  end

  postgres do
    table "live_chat_channel_rules"
    repo UniboExPoc.Repo
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
    attribute :regex_url, :string do
      public? true
      description "URL 正则匹配模式"
    end
    attribute :action, :atom do
      constraints one_of: [:display_button, :display_button_and_text, :auto_popup, :hide_button]
      public? true
      description "匹配后的显示行为"
    end
    attribute :auto_popup_timer, :integer do
      public? true
      description "自动弹出延迟秒数（仅 auto_popup 时有效）"
    end
    attribute :sequence, :integer do
      default 10
      public? true
      description "规则排序优先级（升序）"
    end
    attribute :chatbot_only_if_no_operator, :boolean do
      default false
      public? true
      description "仅当无在线操作员时启用 chatbot"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :channel, UniboExPoc.LiveChat.LiveChatChannel do
      public? true
      allow_nil? false
    end
    many_to_many :country_ids, UniboExPoc.LiveChat.Country do
      public? true
      through UniboExPoc.LiveChat.ChannelRuleCountryLink
    end
    belongs_to :chatbot_script_id, UniboExPoc.LiveChat.ChatbotScript do
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
      description "按优先级匹配频道规则"
      argument :channel_id, :uuid, allow_nil?: false
      argument :url, :string, allow_nil?: false
      argument :country_id, :uuid
    end
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
  end

end
