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
    otp_app: :unibo_ex_poc,
    domain: UniboV4.LiveChat,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource]

  resource do
    description "在线客服频道，管理操作员列表、UI 配置及操作员分配策略"
  end

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
      description "频道名称"
    end
    attribute :button_text, :string do
      default "Have a Question? Chat with us."
      public? true
      description "聊天按钮文本（支持国际化）"
    end
    attribute :default_message, :string do
      default "How may I help you?"
      public? true
      description "欢迎消息（支持国际化）"
    end
    attribute :input_placeholder, :string do
      public? true
      description "输入框占位符（支持国际化）"
    end
    attribute :header_background_color, :string do
      default "#875A7B"
      public? true
      description "头部背景色"
    end
    attribute :title_color, :string do
      default "#FFFFFF"
      public? true
      description "标题颜色"
    end
    attribute :button_background_color, :string do
      default "#875A7B"
      public? true
      description "按钮背景色"
    end
    attribute :button_text_color, :string do
      default "#FFFFFF"
      public? true
      description "按钮文字颜色"
    end
    attribute :image, :string do
      public? true
      description "频道头像 (128x128)"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  calculations do
    calculate :web_page, :string, expr("/im_livechat/support/" <> id)
    calculate :are_you_inside, :boolean, {UniboV4.LiveChat.Calculations.LiveChatChannel.AreYouInside, []}
    calculate :available_operator_ids, {:array, :string}, {UniboV4.LiveChat.Calculations.LiveChatChannel.AvailableOperatorIds, []}
    calculate :nbr_channel, :integer, expr(count(sessions, query: [filter: expr(true)]))
    calculate :chatbot_script_count, :integer, expr(count_distinct(rule_ids.chatbot_script_id))
    calculate :is_available, :boolean, expr((chatbot_script_count > 0 or count(available_operator_ids, query: [filter: expr(true)]) > 0))
  end

  relationships do
    many_to_many :user_ids, UniboV4.LiveChat.Party do
      public? true
      through UniboV4.LiveChat.LiveChatChannelUserLink
      source_attribute_on_join_resource :livechat_channel_id
      destination_attribute_on_join_resource :user_party_id
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
      change UniboV4.LiveChat.Changes.LiveChatChannel.CreateCall1
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:name, :button_text, :default_message, :input_placeholder, :header_background_color, :title_color, :button_background_color, :button_text_color, :image]
      argument :rule_ids, {:array, :map}, default: []
      change manage_relationship(:rule_ids, :rule_ids, on_lookup: :relate, on_no_match: :create, on_match: :update)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :join do
      description "当前用户加入操作员列表"
      accept []
      change UniboV4.LiveChat.Changes.LiveChatChannel.JoinCall2
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :quit do
      description "当前用户退出操作员列表"
      accept []
      change UniboV4.LiveChat.Changes.LiveChatChannel.QuitCall3
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    read :get_livechat_info do
      description "返回频道可用性及 UI 配置"
      argument :username, :string
    end
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
