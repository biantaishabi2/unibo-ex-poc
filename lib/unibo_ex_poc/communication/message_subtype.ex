defmodule UniboV4.Communication.MessageSubtype do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Communication,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "消息子类型占位实体（控制内部可见性与通知语义）"
  end

  postgres do
    table "communication_message_subtypes"
    repo UniboV4.Repo
  end

  graphql do
    type :communication_message_subtype

    queries do
      get :get_communication_message_subtype, :read
      list :list_communication_message_subtypes, :read
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :code, :string, public?: true
    attribute :internal, :boolean do
      default false
      public? true
    end
  end

  actions do
    defaults [:read, :update]
  end

end
