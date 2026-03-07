defmodule UniboExPoc.Ofbiz.Order.CustRequestCommEvent do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Order,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "order_cust_request_comm_events"
    repo UniboExPoc.Repo
  end

  graphql do
    type :order_cust_request_comm_event

    queries do
      get :get_order_cust_request_comm_event, :read
      list :list_order_cust_request_comm_events, :read
    end

    mutations do
      create :create_order_cust_request_comm_event, :create
      update :update_order_cust_request_comm_event, :update
      destroy :delete_order_cust_request_comm_event, :destroy
    end

  end

  attributes do
    attribute :cust_request_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :communication_event_id, :string do
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
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
