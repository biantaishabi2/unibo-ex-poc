defmodule UniboExPoc.Ofbiz.Product.SubscriptionActivity do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Product,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "product_subscription_activities"
    repo UniboExPoc.Repo
  end

  graphql do
    type :product_subscription_activity

    queries do
      get :get_product_subscription_activity, :read
      list :list_product_subscription_activitys, :read
    end

    mutations do
      create :create_product_subscription_activity, :create
      update :update_product_subscription_activity, :update
      destroy :delete_product_subscription_activity, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :subscription_activity_id, :string, public?: true
    attribute :comments, :string, public?: true
    attribute :date_sent, :utc_datetime, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
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
