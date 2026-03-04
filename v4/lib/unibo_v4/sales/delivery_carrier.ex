# Workflow: delivery_carrier_lifecycle — 配送方式管理流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> rate_shipment
#   create --> destroy
#   update --> update
#   update --> rate_shipment
#   update --> destroy
#   rate_shipment --> update
#   rate_shipment --> rate_shipment
#   destroy --> [*]
# ```
defmodule UniboV4.Sales.DeliveryCarrier do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Sales,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "sales_delivery_carriers"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
    end
    attribute :active, :boolean do
      default true
      public? true
    end
    attribute :sequence, :integer do
      default 10
      public? true
    end
    attribute :delivery_type, :atom do
      constraints one_of: [:fixed, :base_on_rule]
      default :fixed
      public? true
    end
    attribute :fixed_price, :decimal do
      default 0
      public? true
    end
    attribute :free_over, :boolean do
      default false
      public? true
    end
    attribute :amount, :decimal do
      default 0
      public? true
    end
    attribute :margin, :decimal do
      default 0
      public? true
    end
    attribute :fixed_margin, :decimal do
      default 0
      public? true
    end
    attribute :carrier_description, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :price_rules, UniboV4.Sales.DeliveryPriceRule do
      public? true
      destination_attribute :carrier_id
    end
    belongs_to :product, UniboV4.Sales.Product do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:name, :active, :sequence, :delivery_type, :fixed_price, :free_over, :amount, :margin, :fixed_margin, :carrier_description]
      argument :product_id, :uuid, allow_nil?: false
      change manage_relationship(:product_id, :product, type: :append, on_lookup: :relate)
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
    read :list do
    end
    read :search do
    end
    read :get do
    end
    read :preview do
    end
    read :compute do
    end
    read :lookup do
    end
    update :update do
      primary? true
      accept [:name, :active, :sequence, :delivery_type, :fixed_price, :free_over, :amount, :margin, :fixed_margin, :carrier_description]
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
    action :rate_shipment do
      argument :order_id, :uuid, allow_nil?: false
      # TODO: generic action 不支持 change，需要用 run
    end
  end

  validations do
    validate compare(:fixed_price, greater_than_or_equal_to: 0)
    validate compare(:amount, greater_than_or_equal_to: 0)
    validate compare(:margin, greater_than_or_equal_to: 0)
  end

end
