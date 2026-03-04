# Workflow: rule_lifecycle — 解析规则维护流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> reorder
#   create --> destroy
#   update --> reorder
#   update --> destroy
#   reorder --> update
#   reorder --> destroy
#   destroy --> [*]
# ```
defmodule UniboV4.Barcode.BarcodeRule do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Barcode,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "barcode_rules"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
    end
    attribute :sequence, :integer do
      allow_nil? false
      default 10
      public? true
    end
    attribute :encoding, :atom do
      allow_nil? false
      constraints one_of: [:any, :ean13, :ean8, :upca, :gs1_128, :gs1_datamatrix]
      default :any
      public? true
    end
    attribute :barcode_type, :atom do
      allow_nil? false
      constraints one_of: [:product, :alias, :quantity, :lot, :location, :location_dest, :package, :package_type, :use_date, :expiration_date, :pack_date]
      default :product
      public? true
    end
    attribute :pattern, :string do
      allow_nil? false
      default ".*"
      public? true
    end
    attribute :alias, :string, public?: true
    attribute :gs1_content_type, :atom do
      constraints one_of: [:date, :measure, :identifier, :alpha]
      public? true
    end
    attribute :gs1_decimal_usage, :boolean do
      default false
      public? true
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :nomenclature, UniboV4.Barcode.BarcodeNomenclature do
      public? true
      allow_nil? false
    end
    belongs_to :gs1_ai, UniboV4.Barcode.GS1ApplicationIdentifier do
      public? true
    end
    has_many :translations, UniboV4.Barcode.BarcodeRuleTranslation, public?: true
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:name, :sequence, :encoding, :barcode_type, :pattern, :alias, :gs1_content_type, :gs1_decimal_usage]
      argument :nomenclature_id, :uuid, allow_nil?: false
      argument :gs1_ai_id, :uuid
      change manage_relationship(:nomenclature_id, :nomenclature, type: :append, on_lookup: :relate)
      validate present(:name)
      validate present(:nomenclature_id)
      validate present(:pattern)
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
      accept [:name, :sequence, :encoding, :barcode_type, :pattern, :alias, :gs1_content_type, :gs1_decimal_usage]
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
    update :reorder do
      accept [:sequence]
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
    validate compare(:sequence, greater_than: 0)
  end

end
