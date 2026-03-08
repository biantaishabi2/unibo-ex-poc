# Workflow: landed_cost_line_write_flow — 到岸成本行写操作覆盖流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
# ```
defmodule UniboExPoc.Inventory.LandedCostLine do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Inventory,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource]

  resource do
    description "到岸成本行，记录每项附加成本（运费、关税等）及分摊方式"
  end

  postgres do
    table "inventory_landed_cost_lines"
    repo UniboExPoc.Repo
  end

  graphql do
    type :inventory_landed_cost_line

    queries do
      get :get_inventory_landed_cost_line, :read
      list :list_inventory_landed_cost_lines, :read
    end

    mutations do
      create :create_inventory_landed_cost_line, :create
      update :update_inventory_landed_cost_line, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
      description "成本描述"
    end
    attribute :price_unit, :decimal do
      allow_nil? false
      public? true
      description "成本金额"
    end
    attribute :split_method, :atom do
      allow_nil? false
      constraints one_of: [:equal, :by_quantity, :by_current_cost_price, :by_weight, :by_volume]
      default :equal
      public? true
      description "分摊方式：等额/按数量/按当前成本价/按重量/按体积"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :cost, UniboExPoc.Inventory.LandedCost do
      public? true
      allow_nil? false
    end
    has_many :adjustment_lines, UniboExPoc.Inventory.ValuationAdjustmentLine do
      public? true
      source_attribute :cost_id
      destination_attribute :cost_line_id
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:name, :price_unit, :split_method]
      argument :cost_id, :uuid, allow_nil?: false
      change manage_relationship(:cost_id, :cost, type: :append, on_lookup: :relate)
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
      accept [:name, :price_unit, :split_method]
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
    validate compare(:price_unit, greater_than: 0)
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
