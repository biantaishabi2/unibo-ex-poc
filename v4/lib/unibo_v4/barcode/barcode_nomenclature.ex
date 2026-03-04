# Workflow: nomenclature_lifecycle — 命名法生命周期管理
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> activate
#   create --> deactivate
#   create --> destroy
#   update --> activate
#   update --> deactivate
#   update --> destroy
#   activate --> update
#   activate --> deactivate
#   deactivate --> update
#   deactivate --> activate
#   deactivate --> destroy
#   destroy --> [*]
# ```
defmodule UniboV4.Barcode.BarcodeNomenclature do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Barcode,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "barcode_nomenclatures"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
    end
    attribute :description, :string, public?: true
    attribute :is_gs1_compliant, :boolean do
      default false
      public? true
    end
    attribute :upc_ean_conv, :atom do
      constraints one_of: [:none, :ean2upc, :upc2ean, :always]
      default :none
      public? true
    end
    attribute :gs1_separator_fnc1, :string do
      default "(Alt029|#|\x1D)"
      public? true
    end
    attribute :active, :boolean do
      default true
      public? true
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :rules, UniboV4.Barcode.BarcodeRule do
      public? true
      destination_attribute :nomenclature_id
    end
    has_many :translations, UniboV4.Barcode.BarcodeNomenclatureTranslation, public?: true
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:name, :description, :is_gs1_compliant, :upc_ean_conv, :gs1_separator_fnc1, :active]
      validate present(:name)
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
      accept [:name, :description, :is_gs1_compliant, :upc_ean_conv, :gs1_separator_fnc1, :active]
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

end
