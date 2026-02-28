defmodule UniboV4.POS do
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
    resource UniboV4.POS.PosSession
    resource UniboV4.POS.PosOrder
    resource UniboV4.POS.PosOrderLine
    resource UniboV4.POS.PosPayment
  end
end
