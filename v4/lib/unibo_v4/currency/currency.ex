defmodule UniboV4.Currency.Currency do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Currency,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "currency_currencies"
    repo UniboV4.Repo
  end

  graphql do
    type :currency_currency

    queries do
      get :get_currency_currency, :read
      list :list_currency_currencys, :read
    end

    mutations do
      create :create_currency_currency, :create
      update :update_currency_currency, :update
      destroy :delete_currency_currency, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :code, :string do
      allow_nil? false
      public? true
    end
    attribute :name, :string do
      allow_nil? false
      public? true
    end
    attribute :symbol, :string, public?: true
    attribute :decimal_places, :integer do
      default 2
      public? true
    end
    attribute :active, :boolean do
      default true
      public? true
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :from_rates, UniboV4.Currency.CurrencyRate do
      public? true
      destination_attribute :from_currency_id
    end
    has_many :to_rates, UniboV4.Currency.CurrencyRate do
      public? true
      destination_attribute :to_currency_id
    end
    has_many :translations, UniboV4.Currency.CurrencyTranslation, public?: true
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:code, :name, :symbol, :decimal_places, :active]
    end
    update :update do
      primary? true
      accept [:name, :symbol, :decimal_places, :active]
    end
  end

  identities do
    identity :unique_code, [:code]
  end

end
