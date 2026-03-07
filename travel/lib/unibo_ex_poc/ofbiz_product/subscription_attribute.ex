defmodule UniboExPoc.Ofbiz.Product.SubscriptionAttribute do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Product,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "product_subscription_attributes"
    repo UniboExPoc.Repo
  end

  graphql do
    type :product_subscription_attribute

    queries do
      get :get_product_subscription_attribute, :read
      list :list_product_subscription_attributes, :read
    end

    mutations do
      create :create_product_subscription_attribute, :create
      update :update_product_subscription_attribute, :update
      destroy :delete_product_subscription_attribute, :destroy
    end

  end

  attributes do
    attribute :attr_name, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :attr_value, :string, public?: true
    attribute :attr_description, :string, public?: true
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
