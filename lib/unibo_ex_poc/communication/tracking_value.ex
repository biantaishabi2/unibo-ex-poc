defmodule UniboV4.Communication.TrackingValue do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Communication,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "字段追踪占位实体"
  end

  postgres do
    table "communication_tracking_values"
    repo UniboV4.Repo
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
    belongs_to :message, UniboV4.Communication.Message do
      public? true
    end
  end

  actions do
    defaults [:read, :update]
  end

end
