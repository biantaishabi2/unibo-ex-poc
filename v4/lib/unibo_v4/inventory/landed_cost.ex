# Workflow: landed_cost_lifecycle_flow — 到岸成本正常流转流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
#   button_validate --> [*]
# ```
# Workflow: landed_cost_cancel_flow — 到岸成本取消流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   button_cancel --> [*]
# ```
defmodule UniboV4.Inventory.LandedCost do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Inventory,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "inventory_landed_costs"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
    end
    attribute :date, :date do
      allow_nil? false
      default &Date.utc_today/0
      public? true
    end
    attribute :state, :atom do
      constraints one_of: [:draft, :done, :cancel]
      default :draft
      public? true
    end
    attribute :description, :string, public?: true
    attribute :amount_total, :decimal, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :cost_lines, UniboV4.Inventory.LandedCostLine do
      public? true
      destination_attribute :cost_id
    end
    has_many :valuation_adjustment_lines, UniboV4.Inventory.ValuationAdjustmentLine do
      public? true
      destination_attribute :cost_id
    end
    many_to_many :picking_ids, UniboV4.Inventory.StockPicking do
      public? true
      through UniboV4.Inventory.LandedCostPicking
      destination_attribute_on_join_resource :picking_id
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:date, :description]
      argument :cost_lines, {:array, :map}, default: []
      change manage_relationship(:cost_lines, :cost_lines, type: :create)
      validate present(:date)
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
      accept [:date, :description]
      argument :cost_lines, {:array, :map}, default: []
      change manage_relationship(:cost_lines, :cost_lines, on_lookup: :relate, on_no_match: :create, on_match: :update)
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
    update :button_validate do
      accept []
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
    update :button_cancel do
      accept []
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

end
