defmodule UniboExPoc.Gamification.KarmaRankTranslation do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Gamification,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "gamification_karma_rank_translations"
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
    belongs_to :karma_rank, UniboExPoc.Gamification.KarmaRank do
      public? true
      allow_nil? false
    end
  end

  identities do
    identity :unique_translation, [:karma_rank_id, :locale, :field_name]
  end

  actions do
    defaults [:read, :destroy, create: :*, update: :*]
  end
end
