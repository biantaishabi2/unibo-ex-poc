defmodule UniboV4.Communication.Message do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Communication,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "messages"
    repo UniboV4.Repo
  end

  graphql do
    type :message

    queries do
      get :get_message, :read
      list :list_messages, :read
    end

    mutations do
      create :create_message, :create
      update :mark_read_message, :mark_read
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :content, :string, allow_nil?: false
    attribute :message_type, :atom do
      constraints one_of: [:text, :image, :file, :system]
      default :text
    end
    attribute :is_read, :boolean, default: false
    attribute :sent_at, :utc_datetime, allow_nil?: false
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :channel, UniboV4.Communication.Channel
    belongs_to :sender, UniboV4.Accounts.User do
      allow_nil? false
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:content, :message_type, :sent_at]
      argument :channel_id, :uuid
      argument :sender_id, :uuid, allow_nil?: false
      change manage_relationship(:sender_id, :sender, type: :append, on_lookup: :relate)
      validate present(:content)
      change relate_actor(:sender)
    end
    update :mark_read do
      accept []
      change set_attribute(:is_read, :true)
    end
  end

end
