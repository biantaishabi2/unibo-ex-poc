# Workflow: bom_line_maintenance_flow — BOM 行创建与更新流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
# ```
defmodule UniboV4.Manufacturing.BomLine do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Manufacturing,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "manufacturing_bom_lines"
    repo UniboV4.Repo
  end

  graphql do
    type :manufacturing_bom_line

    mutations do
      create :create_manufacturing_bom_line, :create
      update :update_manufacturing_bom_line, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :product_id, :uuid do
      allow_nil? false
      public? true
    end
    attribute :component_name, :string do
      allow_nil? false
      public? true
    end
    attribute :component_code, :string do
      allow_nil? false
      public? true
    end
    attribute :product_qty, :decimal do
      allow_nil? false
      public? true
    end
    attribute :product_uom_id, :uuid do
      allow_nil? false
      public? true
    end
    attribute :unit, :string do
      default "PCS"
      public? true
    end
    attribute :manual_consumption, :boolean do
      default false
      public? true
    end
    attribute :bom_product_template_attribute_value_ids, :map, public?: true
    attribute :sequence, :integer, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :bom, UniboV4.Manufacturing.BillOfMaterials do
      public? true
      allow_nil? false
    end
    belongs_to :operation, UniboV4.Manufacturing.RoutingOperation do
      public? true
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:product_id, :component_name, :component_code, :product_qty, :product_uom_id, :unit, :manual_consumption, :sequence]
      argument :bom_id, :uuid, allow_nil?: false
      change manage_relationship(:bom_id, :bom, type: :append, on_lookup: :relate)
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
      accept [:product_qty, :product_uom_id, :unit, :manual_consumption, :sequence]
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
    validate compare(:product_qty, greater_than: 0)
  end

end
