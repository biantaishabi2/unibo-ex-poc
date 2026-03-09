defmodule UniboExPoc.Payment do
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
    resource UniboExPoc.Payment.PaymentType
    resource UniboExPoc.Payment.PaymentType.Version
    resource UniboExPoc.Payment.PaymentProvider
    resource UniboExPoc.Payment.PaymentProvider.Version
    resource UniboExPoc.Payment.PaymentMethod
    resource UniboExPoc.Payment.PaymentMethod.Version
    resource UniboExPoc.Payment.Payment
    resource UniboExPoc.Payment.Payment.Version
    resource UniboExPoc.Payment.PaymentRefund
    resource UniboExPoc.Payment.PaymentRefund.Version
    resource UniboExPoc.Payment.PaymentToken
    resource UniboExPoc.Payment.PaymentToken.Version
    resource UniboExPoc.Payment.PaymentGatewayResponse
    resource UniboExPoc.Payment.PaymentGatewayResponse.Version
    resource UniboExPoc.Payment.PaymentApplication
    resource UniboExPoc.Payment.PaymentApplication.Version
    resource UniboExPoc.Payment.Party
    resource UniboExPoc.Payment.Invoice
  end
end
