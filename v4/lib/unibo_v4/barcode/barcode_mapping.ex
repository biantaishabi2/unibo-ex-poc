# Workflow: mapping_lifecycle — 条码映射生命周期
# ```mermaid
# stateDiagram-v2
#   [*] --> register
#   register --> update
#   register --> deactivate
#   register --> destroy
#   update --> deactivate
#   update --> destroy
#   deactivate --> update
#   deactivate --> destroy
#   destroy --> [*]
# ```
defmodule UniboV4.Barcode.Barcode.BarcodeMapping do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Barcode.Barcode,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource],
    notifiers: [UniboV4.Barcode.Barcode.BarcodeMapping.Notifier]

  postgres do
    table "barcode_mappings"
    repo UniboV4.Repo
  end

  graphql do
    type :barcode_barcode_mapping

    queries do
      get :get_barcode_barcode_mapping, :read
      list :list_barcode_barcode_mappings, :read
    end

    mutations do
      create :create_register_barcode_barcode_mapping, :register
      update :update_barcode_barcode_mapping, :update
      update :deactivate_barcode_barcode_mapping, :deactivate
      destroy :delete_barcode_barcode_mapping, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :barcode_value, :string do
      allow_nil? false
      public? true
    end
    attribute :resource_type, :string do
      allow_nil? false
      public? true
    end
    attribute :resource_id, :string do
      allow_nil? false
      public? true
    end
    attribute :active, :boolean do
      default true
      public? true
    end
    attribute :description, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :nomenclature, UniboV4.Barcode.Barcode.BarcodeNomenclature do
      public? true
    end
  end

  actions do
    defaults [:read, :destroy]
    create :register do
      primary? true
      accept [:barcode_value, :resource_type, :resource_id, :description]
      argument :nomenclature_id, :uuid
      validate present(:barcode_value)
      validate present(:resource_type)
      validate present(:resource_id)
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
      accept [:resource_type, :resource_id, :description, :active]
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
    update :deactivate do
      accept []
      # TODO: 不支持的表达式类型
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

  identities do
    identity :unique_barcode_value, [:barcode_value]
  end

end
