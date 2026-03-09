defmodule UniboExPoc.Uom.UomCategoryTranslation do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Uom,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "uom_uom_category_translations"
    repo UniboExPoc.Repo
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
    belongs_to :uom_category, UniboExPoc.Uom.UomCategory do
      public? true
      allow_nil? false
    end
  end

  identities do
    identity :unique_translation, [:uom_category_id, :locale, :field_name]
  end

  actions do
    defaults [:read, :destroy, create: :*, update: :*]
  end
end
