defmodule UniboV4.Subscriptions do
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
    resource UniboV4.Subscriptions.SubscriptionPlan
    resource UniboV4.Subscriptions.SubscriptionOrder
    resource UniboV4.Subscriptions.SubscriptionOrderLine
    resource UniboV4.Subscriptions.CloseReason
    resource UniboV4.Subscriptions.SubscriptionLog
    resource UniboV4.Subscriptions.SubscriptionOrderLineTaxLink
    resource UniboV4.Subscriptions.Currency
    resource UniboV4.Subscriptions.User
    resource UniboV4.Subscriptions.Partner
    resource UniboV4.Subscriptions.PaymentToken
    resource UniboV4.Subscriptions.Pricelist
    resource UniboV4.Subscriptions.Stage
    resource UniboV4.Subscriptions.SalesTeam
    resource UniboV4.Subscriptions.Product
    resource UniboV4.Subscriptions.Tax
  end
end
