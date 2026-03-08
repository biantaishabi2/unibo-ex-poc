# Workflow: rental_pricing_maintain_flow — 租赁定价规则维护
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> destroy
#   update --> destroy
#   destroy --> [*]
# ```
defmodule UniboExPoc.Rental.RentalPricing do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Rental,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "租赁定价规则（cheapest-line 算法：遍历所有适用规则，自动选择最便宜方案）"
  end

  postgres do
    table "rental_pricings"
    repo UniboExPoc.Repo
  end

  graphql do
    type :rental_rental_pricing

    queries do
      get :get_rental_rental_pricing, :read
      list :list_rental_rental_pricings, :read
    end

    mutations do
      create :create_rental_rental_pricing, :create
      update :update_rental_rental_pricing, :update
      destroy :delete_rental_rental_pricing, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :product_tmpl_id, :uuid do
      allow_nil? false
      public? true
      description "关联产品模板"
    end
    attribute :duration, :integer do
      allow_nil? false
      public? true
      description "时长数值（如 1, 7, 30）"
    end
    attribute :unit, :atom do
      allow_nil? false
      constraints one_of: [:hour, :day, :week, :month, :year]
      public? true
      description "时间单位"
    end
    attribute :price, :decimal do
      allow_nil? false
      public? true
      description "该档位的租赁价格"
    end
    attribute :currency_id, :uuid do
      allow_nil? false
      public? true
      description "币种"
    end
    attribute :company_id, :uuid do
      allow_nil? false
      public? true
      description "所属公司"
    end
    attribute :active, :boolean do
      allow_nil? false
      default true
      public? true
      description "是否启用"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :product_template, UniboExPoc.Rental.ProductTemplate do
      public? true
      allow_nil? false
    end
    belongs_to :pricelist, UniboExPoc.Rental.Pricelist do
      public? true
    end
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:product_tmpl_id, :duration, :unit, :price, :pricelist_id, :currency_id, :company_id]
      argument :product_template_id, :uuid, allow_nil?: false
      change manage_relationship(:product_template_id, :product_template, type: :append, on_lookup: :relate)
    end
    update :update do
      primary? true
      accept [:duration, :unit, :price, :pricelist_id, :active]
      require_atomic? false
    end
  end

  validations do
    validate compare(:price, greater_than_or_equal_to: 0)
    validate compare(:duration, greater_than: 0)
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
  end

end
