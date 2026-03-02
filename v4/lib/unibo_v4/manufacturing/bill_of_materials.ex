defmodule UniboV4.Manufacturing.BillOfMaterials do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Manufacturing,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "bill_of_materialses"
    repo UniboV4.Repo
  end

  graphql do
    type :bill_of_materials

    queries do
      get :get_bill_of_materials, :read
      list :list_bill_of_materialss, :read
    end

    mutations do
      create :create_bill_of_materials, :create
      update :update_bill_of_materials, :update
      update :activate_bill_of_materials, :activate
      update :obsolete_bill_of_materials, :obsolete
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :bom_code, :string, allow_nil?: false, public?: true
    attribute :product_name, :string, allow_nil?: false, public?: true
    attribute :product_code, :string, allow_nil?: false, public?: true
    attribute :version, :string, default: "1.0", public?: true
    attribute :status, :atom do
      constraints one_of: [:draft, :active, :obsolete]
      default :draft
        public? true
    end
    attribute :description, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :lines, UniboV4.Manufacturing.BomLine
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:bom_code, :product_name, :product_code, :version, :description]
      argument :lines, {:array, :string}, allow_nil?: false
      change manage_relationship(:lines, :lines, type: :create)
      validate present(:bom_code)
    end
    update :update do
      primary? true
      accept [:version, :description, :status]
      argument :lines, {:array, :map}, default: []
      change manage_relationship(:lines, :lines, on_lookup: :relate, on_no_match: :create, on_match: :update)
    end
    update :activate do
      accept []
      argument :lines, {:array, :map}, default: []
      change manage_relationship(:lines, :lines, on_lookup: :relate, on_no_match: :create, on_match: :update)
      validate attribute_equals(:status, :draft) do
        message "只有草稿状态可以激活"
      end
      change set_attribute(:status, :active)
    end
    update :obsolete do
      accept []
      argument :lines, {:array, :map}, default: []
      change manage_relationship(:lines, :lines, on_lookup: :relate, on_no_match: :create, on_match: :update)
      validate attribute_equals(:status, :active) do
        message "只有激活状态可以废弃"
      end
      change set_attribute(:status, :obsolete)
    end
  end

  identities do
    identity :unique_bom_code, [:bom_code]
  end

end
