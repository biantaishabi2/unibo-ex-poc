defmodule UniboV4.Rating.RatingCriteriaTranslation do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Rating,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "rating_rating_criteria_translations"
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
    belongs_to :rating_criteria, UniboV4.Rating.RatingCriteria do
      public? true
      allow_nil? false
    end
  end

  identities do
    identity :unique_translation, [:rating_criteria_id, :locale, :field_name]
  end

  actions do
    defaults [:read, :destroy, create: :*, update: :*]
  end
end
