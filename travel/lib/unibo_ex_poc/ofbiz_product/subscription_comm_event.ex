defmodule UniboExPoc.Ofbiz.Product.SubscriptionCommEvent do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Product,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "product_subscription_comm_events"
    repo UniboExPoc.Repo
  end

  graphql do
    type :product_subscription_comm_event

    queries do
      get :get_product_subscription_comm_event, :read
      list :list_product_subscription_comm_events, :read
    end

    mutations do
      create :create_product_subscription_comm_event, :create
      update :update_product_subscription_comm_event, :update
      destroy :delete_product_subscription_comm_event, :destroy
    end

  end

  attributes do
    attribute :communication_event_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :subscription, UniboExPoc.Ofbiz.Product.Subscription do
      public? true
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
