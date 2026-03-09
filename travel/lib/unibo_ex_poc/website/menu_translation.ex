defmodule UniboExPoc.Website.MenuTranslation do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Website,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "website_menu_translations"
    repo UniboExPoc.Repo
    identity_index_names unique_translation: "idx_menu_i18n_uniq"
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
    belongs_to :menu, UniboExPoc.Website.Menu do
      public? true
      allow_nil? false
    end
  end

  identities do
    identity :unique_translation, [:menu_id, :locale, :field_name]
  end

  actions do
    defaults [:read, :destroy, create: :*, update: :*]
  end
end
