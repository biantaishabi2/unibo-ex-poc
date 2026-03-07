defmodule UniboExPoc.Ofbiz.Product.SubscriptionFulfillmentPiece do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Product,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "product_subscription_fulfillment_pieces"
    repo UniboExPoc.Repo
  end

  graphql do
    type :product_subscription_fulfillment_piece

    queries do
      get :get_product_subscription_fulfillment_piece, :read
      list :list_product_subscription_fulfillment_pieces, :read
    end

    mutations do
      create :create_product_subscription_fulfillment_piece, :create
      update :update_product_subscription_fulfillment_piece, :update
      destroy :delete_product_subscription_fulfillment_piece, :destroy
    end

  end

  attributes do
    attribute :subscription_activity_id, :uuid do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :subscription_id, :uuid do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :subscription, UniboExPoc.Ofbiz.Product.Subscription do
      public? true
      define_attribute? false
    end
    belongs_to :subscription_activity, UniboExPoc.Ofbiz.Product.SubscriptionActivity do
      public? true
      define_attribute? false
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
