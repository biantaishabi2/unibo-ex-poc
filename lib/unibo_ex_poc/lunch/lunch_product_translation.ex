defmodule UniboV4.Lunch.LunchProductTranslation do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Lunch,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "lunch_lunch_product_translations"
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
    belongs_to :lunch_product, UniboV4.Lunch.LunchProduct do
      public? true
      allow_nil? false
    end
  end

  identities do
    identity :unique_translation, [:lunch_product_id, :locale, :field_name]
  end

  actions do
    defaults [:read, :destroy, create: :*, update: :*]
  end
end
