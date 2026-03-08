# Workflow: price_lifecycle — 产品价格管理流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   update --> update
# ```
defmodule UniboExPoc.Ecommerce.ProductPrice do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ecommerce,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource]

  resource do
    description "产品价格"
  end

  postgres do
    table "ecommerce_product_prices"
    repo UniboExPoc.Repo
  end

  graphql do
    type :ecommerce_product_price

    queries do
      get :get_ecommerce_product_price, :read
      list :list_ecommerce_product_prices, :read
    end

    mutations do
      create :create_ecommerce_product_price, :create
      update :update_ecommerce_product_price, :update
    end

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
    calculate :is_active, :boolean, {UniboExPoc.Ecommerce.Calculations.ProductPrice.IsActive, []}
    calculate :effective_price, :decimal, expr(amount)
  end

  relationships do
    belongs_to :product, UniboExPoc.Ecommerce.ProductTemplate do
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
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:amount, :thru_date]
      change UniboExPoc.Ecommerce.Changes.ProductPrice.UpdateCall1
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  validations do
    validate compare(:amount, greater_than_or_equal_to: 0)
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
