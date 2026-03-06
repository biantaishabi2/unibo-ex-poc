defmodule UniboV4.Payment do
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
    resource UniboV4.Payment.PaymentType
    resource UniboV4.Payment.PaymentProvider
    resource UniboV4.Payment.PaymentMethod
    resource UniboV4.Payment.Payment
    resource UniboV4.Payment.PaymentRefund
    resource UniboV4.Payment.PaymentToken
    resource UniboV4.Payment.PaymentGatewayResponse
    resource UniboV4.Payment.PaymentApplication
    resource UniboV4.Payment.Party
    resource UniboV4.Payment.Invoice
  end
end
