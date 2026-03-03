# Workflow: currency_rate_maintain_flow — 汇率维护
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> destroy
#   update --> destroy
#   destroy --> [*]
# ```
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
    attribute :thru_date, :date, public?: true
    attribute :rate_source, :string, public?: true
    attribute :from_currency_id, :uuid, public?: true
    attribute :to_currency_id, :uuid, public?: true
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
      accept [:rate, :effective_date, :thru_date, :rate_source, :from_currency_id, :to_currency_id]
      validate present(:rate)
      validate present(:effective_date)
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
    end
    update :update do
      primary? true
      accept [:rate, :thru_date, :rate_source]
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
      require_atomic? false
    end
  end

  validations do
    validate compare(:rate, greater_than: 0)
  end

  identities do
    identity :unique_rate, [:from_currency_id, :to_currency_id, :effective_date]
  end

end
