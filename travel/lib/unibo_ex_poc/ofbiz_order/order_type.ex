defmodule UniboExPoc.Ofbiz.Order.OrderType do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Order,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "order_types"
    repo UniboExPoc.Repo
  end

  graphql do
    type :ofbiz_order_order_type

    queries do
      get :get_ofbiz_order_order_type, :read
      list :list_ofbiz_order_order_types, :read
    end

    mutations do
      create :create_ofbiz_order_order_type, :create
      update :update_ofbiz_order_order_type, :update
      destroy :delete_ofbiz_order_order_type, :destroy
    end

  end

  attributes do
    attribute :id, :string do
      primary_key? true
      allow_nil? false
      public? true
    end
    attribute :order_type_id, :string, public?: true
    attribute :has_table, :boolean, public?: true
    attribute :description, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :parent_order_type, UniboExPoc.Ofbiz.Order.OrderType do
      public? true
      source_attribute :parent_type_id
      attribute_type :string
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
