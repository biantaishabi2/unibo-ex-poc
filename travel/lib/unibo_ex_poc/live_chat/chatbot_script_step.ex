defmodule UniboExPoc.LiveChat.ChatbotScriptStep do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.LiveChat,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "跨域聊天脚本步骤占位实体"
  end

  postgres do
    table "live_chat_chatbot_script_steps"
    repo UniboExPoc.Repo
  end

  graphql do
    type :live_chat_chatbot_script_step

    queries do
      get :get_live_chat_chatbot_script_step, :read
      list :list_live_chat_chatbot_script_steps, :read
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string, public?: true
  end

  actions do
    defaults [:read, :update]
  end

end
