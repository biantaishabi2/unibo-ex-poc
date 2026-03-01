defmodule UniboV4.Currency.CurrencyRate do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Currency,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "currency_rates"
    repo UniboV4.Repo
  end

  graphql do
    type :currency_currency_rate

    queries do
      get :get_currency_currency_rate, :read
      list :list_currency_currency_rates, :read
    end

    mutations do
      create :create_currency_currency_rate, :create
      update :update_currency_currency_rate, :update
      destroy :delete_currency_currency_rate, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :rate, :decimal do
      allow_nil? false
      public? true
    end
    attribute :effective_date, :date do
      allow_nil? false
      public? true
    end
    attribute :source, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :from_currency, UniboV4.Currency.Currency do
      public? true
    end
    belongs_to :to_currency, UniboV4.Currency.Currency do
      public? true
    end
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:rate, :effective_date, :source]
      argument :from_currency_id, :uuid
      argument :to_currency_id, :uuid
      change manage_relationship(:from_currency_id, :from_currency, type: :append_and_remove)
      change manage_relationship(:to_currency_id, :to_currency, type: :append_and_remove)
    end
    update :update do
      primary? true
      accept [:rate, :source]
    end
  end

end
