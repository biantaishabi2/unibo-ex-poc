defmodule UniboV4.Barcode.BarcodeRuleTranslation do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Barcode,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "barcode_barcode_rule_translations"
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
    belongs_to :barcode_rule, UniboV4.Barcode.BarcodeRule do
      public? true
      allow_nil? false
    end
  end

  identities do
    identity :unique_translation, [:barcode_rule_id, :locale, :field_name]
  end

  actions do
    defaults [:read, :destroy, create: :*, update: :*]
  end
end
