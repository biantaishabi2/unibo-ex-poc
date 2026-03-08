defmodule UniboV4.Currency do
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
    resource UniboV4.Currency.Currency
    resource UniboV4.Currency.CurrencyTranslation
    resource UniboV4.Currency.Currency.Version
    resource UniboV4.Currency.CurrencyRate
    resource UniboV4.Currency.CurrencyRate.Version
  end
end
