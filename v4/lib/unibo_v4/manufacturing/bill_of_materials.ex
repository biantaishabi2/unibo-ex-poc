# Workflow: bom_lifecycle_flow — BOM 创建、维护、激活与废弃流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
#   activate --> [*]
#   obsolete --> [*]
# ```
defmodule UniboV4.Manufacturing.BillOfMaterials do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Manufacturing,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "manufacturing_bill_of_materialses"
    repo UniboV4.Repo
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
    end
    attribute :product_tmpl_id, :uuid do
      allow_nil? false
      public? true
    end
    attribute :product_id, :uuid, public?: true
    attribute :product_name, :string do
      allow_nil? false
      public? true
    end
    attribute :product_code, :string do
      allow_nil? false
      public? true
    end
    attribute :product_qty, :decimal do
      allow_nil? false
      default 1.0
      public? true
    end
    attribute :product_uom_id, :uuid do
      allow_nil? false
      public? true
    end
    attribute :type, :atom do
      constraints one_of: [:normal, :phantom]
      default :normal
      public? true
    end
    attribute :consumption, :atom do
      constraints one_of: [:flexible, :warning, :strict]
      default :flexible
      public? true
    end
    attribute :sequence, :integer do
      default 1
      public? true
    end
    attribute :version, :string do
      default "1.0"
      public? true
    end
    attribute :status, :atom do
      constraints one_of: [:draft, :active, :obsolete]
      default :draft
      public? true
    end
    attribute :active, :boolean do
      default true
      public? true
    end
    attribute :company_id, :uuid, public?: true
    attribute :description, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  calculations do
    # TODO: 不支持的 calculation 表达式 :explode_result
    # TODO: 不支持的 calculation 表达式 :bom_find_priority
  end

  relationships do
    has_many :lines, UniboV4.Manufacturing.BomLine do
      public? true
      destination_attribute :bom_id
    end
    has_many :byproducts, UniboV4.Manufacturing.BomByproduct do
      public? true
      destination_attribute :bom_id
    end
    has_many :operations, UniboV4.Manufacturing.RoutingOperation do
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
      accept [:product_qty, :product_uom_id, :type, :consumption, :version, :description, :status, :active]
      argument :lines, {:array, :map}, default: []
      change manage_relationship(:lines, :lines, on_lookup: :relate, on_no_match: :create, on_match: :update)
      argument :byproducts, {:array, :map}, default: []
      change manage_relationship(:byproducts, :byproducts, on_lookup: :relate, on_no_match: :create, on_match: :update)
      argument :operations, {:array, :map}, default: []
      change manage_relationship(:operations, :operations, on_lookup: :relate, on_no_match: :create, on_match: :update)
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
    update :activate do
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
    update :obsolete do
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
    read :explode do
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

end
