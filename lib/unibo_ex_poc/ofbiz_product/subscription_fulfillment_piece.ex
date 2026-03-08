defmodule UniboV4.Ofbiz.Product.SubscriptionFulfillmentPiece do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Ofbiz.Product,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "product_subscription_fulfillment_pieces"
    repo UniboV4.Repo
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
    uuid_primary_key :id
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :subscription, UniboV4.Ofbiz.Product.Subscription do
      public? true
    end
    belongs_to :subscription_activity, UniboV4.Ofbiz.Product.SubscriptionActivity do
      public? true
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
  end

end
