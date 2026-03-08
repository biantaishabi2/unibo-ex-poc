# Workflow: currency_rate_maintain_flow — 汇率维护
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> destroy
#   update --> destroy
#   destroy --> [*]
# ```
defmodule UniboExPoc.Currency.CurrencyRate do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Currency,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "币种汇率（带生效/失效日期的换算记录，对齐 OFBiz UomConversionDated）"
  end

  postgres do
    table "currency_rates"
    repo UniboExPoc.Repo
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
      description "换算比率（对齐 UomConversionDated.conversion_factor）"
    end
    attribute :effective_date, :date do
      allow_nil? false
      public? true
      description "生效日期（对齐 UomConversionDated.from_date）"
    end
    attribute :thru_date, :date do
      public? true
      description "失效日期（对齐 UomConversionDated.thru_date，为空表示长期有效）"
    end
    attribute :rate_source, :string do
      public? true
      description "汇率来源（如 央行、手动录入）"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :from_currency, UniboExPoc.Currency.Currency do
      public? true
    end
    belongs_to :to_currency, UniboExPoc.Currency.Currency do
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

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
  end

end
