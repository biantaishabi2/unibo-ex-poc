defmodule UniboV4.Gamification.ResUser do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Gamification,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "gamification_res_users"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string, public?: true
    attribute :karma, :integer do
      default 0
      public? true
    end
  end

  relationships do
    belongs_to :rank, UniboV4.Gamification.KarmaRank do
      public? true
    end
    belongs_to :next_rank, UniboV4.Gamification.KarmaRank do
      public? true
    end
    has_many :karma_tracking_ids, UniboV4.Gamification.KarmaTracking do
      public? true
      destination_attribute :user_id
    end
    has_many :badge_ids, UniboV4.Gamification.BadgeUser do
      public? true
      destination_attribute :user_id
    end
    has_many :goals, UniboV4.Gamification.Goal do
      public? true
      destination_attribute :user_id
    end
  end

  actions do
    defaults [:read]
  end

end
