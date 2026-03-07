defmodule UniboExPoc.Ofbiz.Order.CustRequestContent do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Order,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "order_cust_request_contents"
    repo UniboExPoc.Repo
  end

  graphql do
    type :order_cust_request_content

    queries do
      get :get_order_cust_request_content, :read
      list :list_order_cust_request_contents, :read
    end

    mutations do
      create :create_order_cust_request_content, :create
      update :update_order_cust_request_content, :update
      destroy :delete_order_cust_request_content, :destroy
    end

  end

  attributes do
    attribute :cust_request_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :content_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :from_date, :utc_datetime do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :thru_date, :utc_datetime, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :cust_request, UniboExPoc.Ofbiz.Order.CustRequest do
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
