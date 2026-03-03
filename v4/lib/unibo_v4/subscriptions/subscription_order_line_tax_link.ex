defmodule UniboV4.Subscriptions.SubscriptionOrderLineTaxLink do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Subscriptions,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "subscriptions_subscription_order_line_tax_links"
    repo UniboV4.Repo
  end

  graphql do
    type :subscriptions_subscription_order_line_tax_link

    queries do
      get :get_subscriptions_subscription_order_line_tax_link, :read
      list :list_subscriptions_subscription_order_line_tax_links, :read
    end

  end

  attributes do
    uuid_primary_key :id
  end

  relationships do
    belongs_to :order_line, UniboV4.Subscriptions.SubscriptionOrderLine do
      public? true
      allow_nil? false
    end
    belongs_to :tax, UniboV4.Subscriptions.Tax do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read, :update]
  end

end
