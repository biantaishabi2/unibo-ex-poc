# Workflow: chat_session_lifecycle — 聊天会话生命周期
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> close
#   close --> [*]
# ```
defmodule UniboV4.LiveChat.ChatSession do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.LiveChat,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource],
    notifiers: [UniboV4.LiveChat.ChatSession.Notifier]

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
    end
    attribute :anonymous_name, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  calculations do
    # TODO: 不支持的 calculation 表达式 :display_name
  end

  relationships do
    belongs_to :livechat_channel, UniboV4.LiveChat.LiveChatChannel do
      public? true
      allow_nil? false
    end
    belongs_to :operator, UniboV4.LiveChat.User do
      public? true
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
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
    end
    update :close do
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
  end

end
