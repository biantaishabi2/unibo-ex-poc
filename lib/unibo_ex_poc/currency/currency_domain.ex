defmodule UniboExPoc.Currency do
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
    resource UniboExPoc.Currency.Currency
    resource UniboExPoc.Currency.CurrencyTranslation
    resource UniboExPoc.Currency.Currency.Version
    resource UniboExPoc.Currency.CurrencyRate
    resource UniboExPoc.Currency.CurrencyRate.Version
  end
end
