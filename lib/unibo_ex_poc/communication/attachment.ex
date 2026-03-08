defmodule UniboV4.Communication.Attachment do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Communication,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "附件占位实体"
  end

  postgres do
    table "communication_attachments"
    repo UniboV4.Repo
  end

  graphql do
    type :communication_attachment

    queries do
      get :get_communication_attachment, :read
      list :list_communication_attachments, :read
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string, public?: true
  end

  relationships do
    belongs_to :message, UniboV4.Communication.Message do
      public? true
    end
  end

  actions do
    defaults [:read, :update]
  end

end
