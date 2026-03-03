defmodule UniboV4.LiveChat.ChatbotScript do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.LiveChat,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "live_chat_chatbot_scripts"
    repo UniboV4.Repo
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
