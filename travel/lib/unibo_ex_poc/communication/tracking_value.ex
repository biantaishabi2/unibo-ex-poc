defmodule UniboExPoc.Communication.TrackingValue do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Communication,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "字段追踪占位实体"
  end

  postgres do
    table "communication_tracking_values"
    repo UniboExPoc.Repo
  end

  graphql do
    type :communication_tracking_value

    queries do
      get :get_communication_tracking_value, :read
      list :list_communication_tracking_values, :read
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :field_name, :string, public?: true
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
