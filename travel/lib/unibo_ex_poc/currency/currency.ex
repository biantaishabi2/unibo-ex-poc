# Workflow: currency_maintain_flow — 币种维护
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> destroy
#   update --> destroy
#   destroy --> [*]
# ```
defmodule UniboExPoc.Currency.Currency do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Currency,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "币种主数据（ISO 4217），本质是计量单位的币种子类型"
  end

  postgres do
    table "currency_currencies"
    repo UniboExPoc.Repo
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
    attribute :name, :string do
      allow_nil? false
      public? true
      description "币种名称（对齐 Uom.description）"
    end
    attribute :factor, :float do
      default 1.0
      public? true
      description "换算比率（币种间通过 CurrencyRate 换算，此处固定 1.0，对齐 Uom.factor）"
    end
    attribute :rounding, :float do
      default 0.01
      public? true
      description "舍入精度（对齐 Uom.rounding）"
    end
    attribute :active, :boolean do
      default true
      public? true
      description "是否启用"
    end
    attribute :code, :string do
      allow_nil? false
      public? true
      description "ISO 4217 币种代码（如 CNY、USD、EUR）"
    end
    attribute :symbol, :string do
      public? true
      description "币种符号（如 ¥、$、€）"
    end
    attribute :decimal_places, :integer do
      default 2
      public? true
      description "小数位数"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  calculations do
    calculate :factor_inv, :float, expr((1 / factor))
  end

  relationships do
    belongs_to :category, UniboExPoc.Uom.UomCategory do
      public? true
    end
    has_many :from_rates, UniboExPoc.Currency.CurrencyRate do
      public? true
      source_attribute :category_id
      destination_attribute :from_currency_id
    end
    has_many :to_rates, UniboExPoc.Currency.CurrencyRate do
      public? true
      source_attribute :category_id
      destination_attribute :to_currency_id
    end
    has_many :translations, UniboExPoc.Currency.CurrencyTranslation, public?: true
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:name, :code, :symbol, :factor, :rounding, :decimal_places, :active]
      argument :category_id, :uuid
      validate present(:code)
      validate present(:name)
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
      accept [:name, :symbol, :factor, :rounding, :decimal_places, :active]
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

  identities do
    identity :unique_code, [:code]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
    archive_related [:from_rates, :to_rates]
  end

end
