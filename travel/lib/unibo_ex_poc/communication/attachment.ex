defmodule UniboExPoc.Communication.Attachment do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Communication,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "附件占位实体"
  end

  postgres do
    table "communication_attachments"
    repo UniboExPoc.Repo
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
    belongs_to :message, UniboExPoc.Communication.Message do
      public? true
    end
  end

  actions do
    defaults [:read, :update]
  end

end
