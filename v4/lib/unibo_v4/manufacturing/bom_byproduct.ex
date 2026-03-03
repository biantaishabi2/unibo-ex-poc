# Workflow: bom_byproduct_maintenance_flow — BOM 副产品创建与更新流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
# ```
defmodule UniboV4.Manufacturing.BomByproduct do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Manufacturing,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "manufacturing_bom_byproducts"
    repo UniboV4.Repo
  end

  graphql do
    type :manufacturing_bom_byproduct

    mutations do
      create :create_manufacturing_bom_byproduct, :create
      update :update_manufacturing_bom_byproduct, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :product_id, :uuid do
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
    attribute :cost_share, :decimal do
      default 0
      public? true
    end
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
      accept [:product_id, :product_qty, :product_uom_id, :cost_share]
      argument :bom_id, :uuid, allow_nil?: false
      change manage_relationship(:bom_id, :bom, type: :append, on_lookup: :relate)
      # TODO: 不支持的 action 内校验规则 custom
      # TODO: 不支持的 action 内校验规则 custom
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
      accept [:product_qty, :product_uom_id, :cost_share]
      # skipped: validate custom : (incompatible with bulk update atomic path)
      # skipped: validate custom : (incompatible with bulk update atomic path)
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
    validate compare(:cost_share, greater_than_or_equal_to: 0, less_than_or_equal_to: 100)
  end

end
