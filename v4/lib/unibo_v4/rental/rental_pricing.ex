# Workflow: rental_pricing_maintain_flow — 租赁定价规则维护
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> destroy
#   update --> destroy
#   destroy --> [*]
# ```
defmodule UniboV4.Rental.RentalPricing do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Rental,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "rental_pricings"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :product_tmpl_id, :uuid do
      allow_nil? false
      public? true
    end
    attribute :duration, :integer do
      allow_nil? false
      public? true
    end
    attribute :unit, :atom do
      allow_nil? false
      constraints one_of: [:hour, :day, :week, :month, :year]
      public? true
    end
    attribute :price, :decimal do
      allow_nil? false
      public? true
    end
    attribute :currency_id, :uuid do
      allow_nil? false
      public? true
    end
    attribute :company_id, :uuid do
      allow_nil? false
      public? true
    end
    attribute :active, :boolean do
      allow_nil? false
      default true
      public? true
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :product_template, UniboV4.Rental.ProductTemplate do
      public? true
      allow_nil? false
    end
    belongs_to :pricelist, UniboV4.Rental.Pricelist do
      public? true
    end
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:product_tmpl_id, :duration, :unit, :price, :currency_id, :company_id]
      argument :product_template_id, :uuid, allow_nil?: false
      change manage_relationship(:product_template_id, :product_template, type: :append, on_lookup: :relate)
    end
    update :update do
      primary? true
      accept [:duration, :unit, :price, :active]
    end
  end

  validations do
    validate compare(:price, greater_than_or_equal_to: 0)
    validate compare(:duration, greater_than: 0)
  end

end
