defmodule UniboV4.Payment.Payment do
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
    resource UniboV4.Payment.Payment.PaymentType
    resource UniboV4.Payment.Payment.PaymentProvider
    resource UniboV4.Payment.Payment.PaymentMethod
    resource UniboV4.Payment.Payment.Payment
    resource UniboV4.Payment.Payment.PaymentRefund
    resource UniboV4.Payment.Payment.PaymentToken
    resource UniboV4.Payment.Payment.PaymentGatewayResponse
    resource UniboV4.Payment.Payment.PaymentApplication
    resource UniboV4.Payment.Payment.Party
    resource UniboV4.Payment.Payment.Invoice
  end
end
