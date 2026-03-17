defmodule UniboExPoc.Ofbiz.Order.OrderRole do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Order,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "order_roles"
    repo UniboExPoc.Repo
  end

  graphql do
    type :ofbiz_order_order_role

    queries do
      get :get_ofbiz_order_order_role, :read
      list :list_ofbiz_order_order_roles, :read
    end

    mutations do
      create :create_ofbiz_order_order_role, :create
      update :update_ofbiz_order_order_role, :update
      destroy :delete_ofbiz_order_order_role, :destroy
    end

  end

  attributes do
    attribute :party_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :role_type_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :order_header, UniboExPoc.Ofbiz.Order.OrderHeader do
      public? true
      source_attribute :order_id
      attribute_type :string
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
