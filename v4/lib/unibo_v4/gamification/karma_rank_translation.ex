defmodule UniboV4.Gamification.KarmaRankTranslation do
  use Ash.Resource,
    otp_app: :unibo_v4,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "gamification_karma_rank_translations"
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
    belongs_to :karma_rank, UniboV4.Gamification.KarmaRank do
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
