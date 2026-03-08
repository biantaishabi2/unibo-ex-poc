defmodule UniboV4.Barcode.GS1ApplicationIdentifierTranslation do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Barcode,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "barcode_gs1_application_identifier_translations"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :locale, :string do
      allow_nil? false
      public? true
    end
    attribute :field_name, :string do
      allow_nil? false
      public? true
    end
    attribute :value, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :gs1_application_identifier, UniboV4.Barcode.GS1ApplicationIdentifier do
      public? true
      allow_nil? false
    end
  end

  identities do
    identity :unique_translation, [:gs1_application_identifier_id, :locale, :field_name]
  end

  actions do
    defaults [:read, :destroy, create: :*, update: :*]
  end
end
