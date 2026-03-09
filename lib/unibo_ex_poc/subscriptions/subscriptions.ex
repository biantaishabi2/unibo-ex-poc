defmodule UniboExPoc.Subscriptions do
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
    resource UniboExPoc.Subscriptions.SubscriptionPlan
    resource UniboExPoc.Subscriptions.SubscriptionPlan.Version
    resource UniboExPoc.Subscriptions.SubscriptionOrder
    resource UniboExPoc.Subscriptions.SubscriptionOrder.Version
    resource UniboExPoc.Subscriptions.SubscriptionOrderLine
    resource UniboExPoc.Subscriptions.SubscriptionOrderLine.Version
    resource UniboExPoc.Subscriptions.CloseReason
    resource UniboExPoc.Subscriptions.CloseReason.Version
    resource UniboExPoc.Subscriptions.SubscriptionLog
    resource UniboExPoc.Subscriptions.SubscriptionOrderLineTaxLink
    resource UniboExPoc.Subscriptions.Currency
    resource UniboExPoc.Subscriptions.PaymentToken
    resource UniboExPoc.Subscriptions.Pricelist
    resource UniboExPoc.Subscriptions.Stage
    resource UniboExPoc.Subscriptions.SalesTeam
    resource UniboExPoc.Subscriptions.Product
    resource UniboExPoc.Subscriptions.Tax
    resource UniboExPoc.Subscriptions.Party
  end
end
