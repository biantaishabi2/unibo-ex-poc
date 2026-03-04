# Workflow: price_lifecycle — 产品价格管理流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   update --> update
# ```
defmodule UniboV4.Ecommerce.ProductPrice do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Ecommerce,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "ecommerce_product_prices"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :price_type, :atom do
      allow_nil? false
      constraints one_of: [:list_price, :sale_price, :cost_price, :member_price]
      public? true
    end
    attribute :amount, :decimal do
      allow_nil? false
      public? true
    end
    attribute :currency, :string do
      default "CNY"
      public? true
    end
    attribute :from_date, :date do
      allow_nil? false
      public? true
    end
    attribute :thru_date, :date, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  calculations do
    # TODO: 不支持的 calculation 表达式 :is_active
    # TODO: 不支持的 calculation 表达式 :effective_price
  end

  relationships do
    belongs_to :product, UniboV4.Ecommerce.ProductTemplate do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:price_type, :amount, :currency, :from_date, :thru_date]
      argument :product_id, :uuid, allow_nil?: false
      change manage_relationship(:product_id, :product, type: :append, on_lookup: :relate)
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
      accept [:amount, :thru_date]
      # TODO: 不支持的 change effect recompute_prices
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
    validate compare(:amount, greater_than_or_equal_to: 0)
  end

end
