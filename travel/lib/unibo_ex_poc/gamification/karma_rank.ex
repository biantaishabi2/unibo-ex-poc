# Workflow: karma_rank_lifecycle_flow — Karma段位创建、更新与删除流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
#   destroy --> [*]
# ```
defmodule UniboExPoc.Gamification.KarmaRank do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Gamification,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "Karma段位定义，按最低karma值划分等级"
  end

  postgres do
    table "gamification_karma_ranks"
    repo UniboExPoc.Repo
  end

  graphql do
    type :gamification_karma_rank

    queries do
      get :get_gamification_karma_rank, :read
      list :list_gamification_karma_ranks, :read
    end

    mutations do
      create :create_gamification_karma_rank, :create
      update :update_gamification_karma_rank, :update
      destroy :delete_gamification_karma_rank, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
      description "段位名称"
    end
    attribute :description, :string do
      public? true
      description "段位描述"
    end
    attribute :description_motivational, :string do
      public? true
      description "激励语"
    end
    attribute :karma_min, :integer do
      allow_nil? false
      default 1
      public? true
      description "最低karma要求"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  calculations do
    calculate :rank_users_count, :integer, {UniboExPoc.Gamification.Calculations.KarmaRank.RankUsersCount, []}
  end

  relationships do
    has_many :translations, UniboExPoc.Gamification.KarmaRankTranslation, public?: true
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:name, :description, :description_motivational, :karma_min]
      validate present(:name)
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:name, :description, :description_motivational, :karma_min]
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  validations do
    validate compare(:karma_min, greater_than: 0)
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
  end

end
