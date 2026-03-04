defmodule UniboV4.Currency do
  use Ash.Domain

  resources do
    resource UniboV4.Currency.Currency
    resource UniboV4.Currency.CurrencyTranslation
    resource UniboV4.Currency.CurrencyRate
  end
end
