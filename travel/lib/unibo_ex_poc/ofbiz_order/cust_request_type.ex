defmodule UniboExPoc.Ofbiz.Order.CustRequestType do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Order,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "order_cust_request_types"
    repo UniboExPoc.Repo
  end

  graphql do
    type :ofbiz_order_cust_request_type

    queries do
      get :get_ofbiz_order_cust_request_type, :read
      list :list_ofbiz_order_cust_request_types, :read
    end

    mutations do
      create :create_ofbiz_order_cust_request_type, :create
      update :update_ofbiz_order_cust_request_type, :update
      destroy :delete_ofbiz_order_cust_request_type, :destroy
    end

  end

  attributes do
    attribute :id, :string do
      primary_key? true
      allow_nil? false
      public? true
    end
    attribute :cust_request_type_id, :string, public?: true
    attribute :has_table, :boolean, public?: true
    attribute :description, :string, public?: true
    attribute :party_id, :string do
      public? true
      description "负责响应此特定类型通信请求的交易方或交易方组（通过partyRelationShip实体）"
    end
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :parent_cust_request_type, UniboExPoc.Ofbiz.Order.CustRequestType do
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
