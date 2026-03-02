defmodule UniboV4.Manufacturing.BomLine do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Manufacturing,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "bom_lines"
    repo UniboV4.Repo
  end

  graphql do
    type :bom_line

    mutations do
      create :create_bom_line, :create
      update :update_bom_line, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :component_name, :string, allow_nil?: false, public?: true
    attribute :component_code, :string, allow_nil?: false, public?: true
    attribute :quantity, :decimal, allow_nil?: false, public?: true
    attribute :unit, :string, default: "PCS", public?: true
    attribute :sequence, :integer, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :bom, UniboV4.Manufacturing.BillOfMaterials do
      allow_nil? false
        public? true
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:component_name, :component_code, :quantity, :unit, :sequence]
      argument :bom_id, :uuid, allow_nil?: false
      change manage_relationship(:bom_id, :bom, type: :append, on_lookup: :relate)
    end
    update :update do
      primary? true
      accept [:quantity, :unit, :sequence]
    end
  end

  validations do
    validate compare(:quantity, greater_than: 0)
  end

end
