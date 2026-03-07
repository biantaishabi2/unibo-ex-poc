defmodule UniboExPoc.Ofbiz.Order.RequirementCustRequest do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Order,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "order_requirement_cust_requests"
    repo UniboExPoc.Repo
  end

  graphql do
    type :order_requirement_cust_request

    queries do
      get :get_order_requirement_cust_request, :read
      list :list_order_requirement_cust_requests, :read
    end

    mutations do
      create :create_order_requirement_cust_request, :create
      update :update_order_requirement_cust_request, :update
      destroy :delete_order_requirement_cust_request, :destroy
    end

  end

  attributes do
    attribute :cust_request_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :cust_request_item_seq_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :requirement_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :cust_request, UniboExPoc.Ofbiz.Order.CustRequest do
      public? true
      define_attribute? false
      attribute_type :string
    end
    belongs_to :requirement, UniboExPoc.Ofbiz.Order.Requirement do
      public? true
      define_attribute? false
      attribute_type :string
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
