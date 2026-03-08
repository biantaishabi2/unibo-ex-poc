defmodule UniboExPoc.LiveChat.ChatbotScript do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.LiveChat,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "跨域聊天脚本占位实体"
  end

  postgres do
    table "live_chat_chatbot_scripts"
    repo UniboExPoc.Repo
  end

  graphql do
    type :live_chat_chatbot_script

    queries do
      get :get_live_chat_chatbot_script, :read
      list :list_live_chat_chatbot_scripts, :read
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
