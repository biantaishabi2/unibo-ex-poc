# Workflow: gs1_ai_maintain_flow — GS1应用标识符维护
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> destroy
#   update --> destroy
#   destroy --> [*]
# ```
defmodule UniboV4.Barcode.GS1ApplicationIdentifier do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Barcode,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "barcode_gs1_application_identifiers"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :ai_code, :string do
      allow_nil? false
      public? true
    end
    attribute :name, :string do
      allow_nil? false
      public? true
    end
    attribute :data_type, :atom do
      allow_nil? false
      constraints one_of: [:identifier, :alpha, :date, :measure]
      public? true
    end
    attribute :fixed_length, :integer, public?: true
    attribute :max_length, :integer, public?: true
    attribute :pattern, :string, public?: true
    attribute :description, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :rules, UniboV4.Barcode.BarcodeRule do
      public? true
      destination_attribute :gs1_ai_id
    end
    has_many :translations, UniboV4.Barcode.GS1ApplicationIdentifierTranslation, public?: true
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:ai_code, :name, :data_type, :fixed_length, :max_length, :pattern, :description]
      validate present(:ai_code)
      validate present(:name)
      validate present(:data_type)
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
      accept [:name, :data_type, :fixed_length, :max_length, :pattern, :description]
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
    identity :unique_ai_code, [:ai_code]
  end

end
