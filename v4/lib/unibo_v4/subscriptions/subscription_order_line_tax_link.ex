defmodule UniboV4.Subscriptions.SubscriptionOrderLineTaxLink do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Subscriptions,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "subscriptions_subscription_order_line_tax_links"
    repo UniboV4.Repo
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
    defaults [:read]
  end

end
