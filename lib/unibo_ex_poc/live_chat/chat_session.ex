# Workflow: chat_session_lifecycle — 聊天会话生命周期
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> close
#   close --> [*]
# ```
defmodule UniboV4.LiveChat.ChatSession do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.LiveChat,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource],
    notifiers: [UniboV4.LiveChat.ChatSession.Notifier]

  resource do
    description "在线客服聊天会话，由访客发起、系统分配操作员"
  end

  postgres do
    table "live_chat_chat_sessions"
    repo UniboV4.Repo
  end

  graphql do
    type :live_chat_chat_session

    queries do
      get :get_live_chat_chat_session, :read
      list :list_live_chat_chat_sessions, :read
    end

    mutations do
      create :create_live_chat_chat_session, :create
      update :close_live_chat_chat_session, :close
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :livechat_active, :boolean do
      default true
      public? true
      description "会话是否活跃"
    end
    attribute :anonymous_name, :string do
      public? true
      description "未注册访客的显示名称"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  calculations do
    calculate :display_name, :string, {UniboV4.LiveChat.Calculations.ChatSession.DisplayName, []}
  end

  relationships do
    belongs_to :livechat_channel, UniboV4.LiveChat.LiveChatChannel do
      public? true
      allow_nil? false
    end
    belongs_to :operator, UniboV4.LiveChat.Party do
      public? true
      source_attribute :operator_party_id
    end
    belongs_to :country, UniboV4.LiveChat.Country do
      public? true
    end
    belongs_to :chatbot_current_step, UniboV4.LiveChat.ChatbotScriptStep do
      public? true
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:anonymous_name]
      argument :livechat_channel_id, :uuid, allow_nil?: false
      argument :previous_operator_id, :uuid
      argument :lang, :string
      argument :country_id, :uuid
      argument :chatbot_script_id, :uuid
      change manage_relationship(:livechat_channel_id, :livechat_channel, type: :append, on_lookup: :relate)
      change UniboV4.LiveChat.Changes.ChatSession.CreateCall1
      change set_attribute(:id, expr(id))
    end
    update :close do
      description "关闭会话（标记为不活跃）"
      primary? true
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :livechat_active)
        if current == true do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :livechat_active, message: "must equal %{value}", vars: %{value: true}))
        end
      end
      # message: "只有活跃会话可以关闭"
      change set_attribute(:livechat_active, false)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
