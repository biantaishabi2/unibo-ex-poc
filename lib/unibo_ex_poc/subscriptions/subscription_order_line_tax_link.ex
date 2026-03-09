defmodule UniboExPoc.Subscriptions.SubscriptionOrderLineTaxLink do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Subscriptions,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "订阅订单行-税率桥接占位实体"
  end

  postgres do
    table "subscriptions_subscription_order_line_tax_links"
    repo UniboExPoc.Repo
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
    belongs_to :order_line, UniboExPoc.Subscriptions.SubscriptionOrderLine do
      public? true
      allow_nil? false
    end
    belongs_to :tax, UniboExPoc.Subscriptions.Tax do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read, :update]
  end

end
