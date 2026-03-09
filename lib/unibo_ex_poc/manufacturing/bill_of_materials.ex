# Workflow: bom_lifecycle_flow — BOM 创建、维护、激活与废弃流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
#   activate --> [*]
#   obsolete --> [*]
# ```
defmodule UniboExPoc.Manufacturing.BillOfMaterials do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Manufacturing,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource]

  resource do
    description "物料清单"
  end

  postgres do
    table "manufacturing_bill_of_materialses"
    repo UniboExPoc.Repo
  end

  graphql do
    type :manufacturing_bill_of_materials

    queries do
      get :get_manufacturing_bill_of_materials, :read
      list :list_manufacturing_bill_of_materialss, :read
      get :get_explode_manufacturing_bill_of_materials, :explode
      list :list_explode_manufacturing_bill_of_materialss, :explode
    end

    mutations do
      create :create_manufacturing_bill_of_materials, :create
      update :update_manufacturing_bill_of_materials, :update
      update :activate_manufacturing_bill_of_materials, :activate
      update :obsolete_manufacturing_bill_of_materials, :obsolete
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :bom_code, :string do
      allow_nil? false
      public? true
      description "BOM 编号"
    end
    attribute :product_tmpl_id, :uuid do
      allow_nil? false
      public? true
      description "产品模板 ID"
    end
    attribute :product_id, :uuid do
      public? true
      description "特定变体 ID（可空，空=适用全部变体）"
    end
    attribute :product_name, :string do
      allow_nil? false
      public? true
      description "成品名称"
    end
    attribute :product_code, :string do
      allow_nil? false
      public? true
      description "成品编号"
    end
    attribute :product_qty, :decimal do
      allow_nil? false
      default 1.0
      public? true
      description "BOM 基准产出数量"
    end
    attribute :product_uom_id, :uuid do
      allow_nil? false
      public? true
      description "BOM 产出单位"
    end
    attribute :type, :atom do
      constraints one_of: [:normal, :phantom]
      default :normal
      public? true
      description "BOM 类型（normal=标准生产，phantom=套件/虚拟件）"
    end
    attribute :consumption, :atom do
      constraints one_of: [:flexible, :warning, :strict]
      default :flexible
      public? true
      description "消耗模式（flexible=不限制，warning=提示，strict=精确匹配）"
    end
    attribute :sequence, :integer do
      default 1
      public? true
      description "排序优先级"
    end
    attribute :version, :string do
      default "1.0"
      public? true
      description "BOM 版本"
    end
    attribute :status, :atom do
      constraints one_of: [:draft, :active, :obsolete]
      default :draft
      public? true
    end
    attribute :active, :boolean do
      default true
      public? true
      description "是否启用"
    end
    attribute :company_id, :uuid do
      public? true
      description "所属公司"
    end
    attribute :description, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  calculations do
    calculate :explode_result, :string, expr(bom_code)
    calculate :bom_find_priority, :integer, expr(sequence)
  end

  relationships do
    has_many :lines, UniboExPoc.Manufacturing.BomLine do
      public? true
      destination_attribute :bom_id
    end
    has_many :byproducts, UniboExPoc.Manufacturing.BomByproduct do
      public? true
      destination_attribute :bom_id
    end
    has_many :operations, UniboExPoc.Manufacturing.RoutingOperation do
      public? true
      destination_attribute :bom_id
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:bom_code, :product_tmpl_id, :product_id, :product_name, :product_code, :product_qty, :product_uom_id, :type, :consumption, :sequence, :version, :description, :company_id]
      argument :lines, {:array, :string}, allow_nil?: false
      argument :byproducts, {:array, :string}
      change manage_relationship(:lines, :lines, type: :create)
      change manage_relationship(:byproducts, :byproducts, type: :create)
      argument :operations, {:array, :map}, default: []
      change manage_relationship(:operations, :operations, type: :create)
      validate present(:bom_code)
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:product_qty, :product_uom_id, :type, :consumption, :version, :description, :status, :active]
      argument :lines, {:array, :map}, default: []
      change manage_relationship(:lines, :lines, on_lookup: :relate, on_no_match: :create, on_match: :update)
      argument :byproducts, {:array, :map}, default: []
      change manage_relationship(:byproducts, :byproducts, on_lookup: :relate, on_no_match: :create, on_match: :update)
      argument :operations, {:array, :map}, default: []
      change manage_relationship(:operations, :operations, on_lookup: :relate, on_no_match: :create, on_match: :update)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :activate do
      description "激活 BOM"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :draft do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :draft}))
        end
      end
      # message: "只有草稿状态可以激活"
      change set_attribute(:status, :active)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :obsolete do
      description "废弃 BOM"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :active do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :active}))
        end
      end
      # message: "只有激活状态可以废弃"
      change set_attribute(:status, :obsolete)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    read :explode do
      description "BOM 展开（递归展开 phantom 套件，返回叶子节点组件列表）"
      argument :quantity, :decimal, allow_nil?: false
      argument :product_id, :uuid
    end
  end

  validations do
    validate compare(:product_qty, greater_than: 0)
  end

  identities do
    identity :unique_bom_code, [:bom_code]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
