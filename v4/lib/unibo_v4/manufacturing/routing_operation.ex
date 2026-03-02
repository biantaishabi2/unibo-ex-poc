defmodule UniboV4.Manufacturing.RoutingOperation do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Manufacturing,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "routing_operations"
    repo UniboV4.Repo
  end

  graphql do
    type :routing_operation

    queries do
      get :get_routing_operation, :read
      list :list_routing_operations, :read
    end

    mutations do
      create :create_routing_operation, :create
      update :update_routing_operation, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :routing_code, :string, allow_nil?: false, public?: true
    attribute :name, :string, allow_nil?: false, public?: true
    attribute :sequence, :integer, allow_nil?: false, public?: true
    attribute :standard_time_hours, :decimal, public?: true
    attribute :description, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :work_center, UniboV4.Manufacturing.WorkCenter, public?: true
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:routing_code, :name, :sequence, :standard_time_hours, :description]
      validate present(:routing_code)
      validate present(:name)
    end
    update :update do
      primary? true
      accept [:name, :sequence, :standard_time_hours, :description]
    end
  end

  identities do
    identity :unique_routing_code, [:routing_code]
  end

end
