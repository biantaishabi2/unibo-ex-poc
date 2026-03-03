# Workflow: livechat_channel_maintain_flow — 客服频道维护流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> join
#   update --> [*]
#   join --> quit
#   quit --> [*]
# ```
defmodule UniboV4.LiveChat.LiveChatChannel do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.LiveChat,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "live_chat_channels"
    repo UniboV4.Repo
  end

  graphql do
    type :live_chat_live_chat_channel

    queries do
      get :get_live_chat_live_chat_channel, :read
      list :list_live_chat_live_chat_channels, :read
      get :get_get_livechat_info_live_chat_live_chat_channel, :get_livechat_info
      list :list_get_livechat_info_live_chat_live_chat_channels, :get_livechat_info
    end

    mutations do
      create :create_live_chat_live_chat_channel, :create
      update :update_live_chat_live_chat_channel, :update
      update :join_live_chat_live_chat_channel, :join
      update :quit_live_chat_live_chat_channel, :quit
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
    end
    attribute :button_text, :string do
      default "Have a Question? Chat with us."
      public? true
    end
    attribute :default_message, :string do
      default "How may I help you?"
      public? true
    end
    attribute :input_placeholder, :string, public?: true
    attribute :header_background_color, :string do
      default "#875A7B"
      public? true
    end
    attribute :title_color, :string do
      default "#FFFFFF"
      public? true
    end
    attribute :button_background_color, :string do
      default "#875A7B"
      public? true
    end
    attribute :button_text_color, :string do
      default "#FFFFFF"
      public? true
    end
    attribute :image, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  calculations do
    # TODO: 不支持的 calculation 表达式 :web_page
    # TODO: 不支持的 calculation 表达式 :are_you_inside
    # TODO: 不支持的 calculation 表达式 :available_operator_ids
    calculate :nbr_channel, :integer, expr(count(sessions, query: [filter: expr(true)]))
    # TODO: 不支持的 calculation 表达式 :chatbot_script_count
    # TODO: 不支持的 calculation 表达式 :is_available
  end

  relationships do
    many_to_many :user_ids, UniboV4.LiveChat.User do
      public? true
      through UniboV4.LiveChat.LiveChatChannelUserLink
    end
    has_many :sessions, UniboV4.LiveChat.ChatSession do
      public? true
      destination_attribute :livechat_channel_id
    end
    has_many :rule_ids, UniboV4.LiveChat.ChannelRule do
      public? true
      destination_attribute :channel_id
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:name, :button_text, :default_message, :input_placeholder, :header_background_color, :title_color, :button_background_color, :button_text_color, :image]
      argument :rule_ids, {:array, :map}, default: []
      change manage_relationship(:rule_ids, :rule_ids, type: :create)
      validate present(:name)
      # TODO: 不支持的 change effect add_relation
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
      accept [:name, :button_text, :default_message, :input_placeholder, :header_background_color, :title_color, :button_background_color, :button_text_color, :image]
      argument :rule_ids, {:array, :map}, default: []
      change manage_relationship(:rule_ids, :rule_ids, on_lookup: :relate, on_no_match: :create, on_match: :update)
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
    update :join do
      accept []
      # TODO: 不支持的 change effect add_relation
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
    update :quit do
      accept []
      # TODO: 不支持的 change effect remove_relation
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
    read :get_livechat_info do
      argument :username, :string
    end
  end

end
