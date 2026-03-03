# Workflow: karma_rank_lifecycle_flow — Karma段位创建、更新与删除流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
#   destroy --> [*]
# ```
defmodule UniboV4.Gamification.KarmaRank do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Gamification,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "gamification_karma_ranks"
    repo UniboV4.Repo
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
    end
    attribute :description, :string, public?: true
    attribute :description_motivational, :string, public?: true
    attribute :karma_min, :integer do
      allow_nil? false
      default 1
      public? true
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  calculations do
    # TODO: 不支持的 calculation 表达式 :rank_users_count
  end

  relationships do
    has_many :users, UniboV4.Gamification.ResUser do
      public? true
      destination_attribute :rank_id
    end
    has_many :translations, UniboV4.Gamification.KarmaRankTranslation, public?: true
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:name, :description, :description_motivational, :karma_min]
      validate present(:name)
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
    end
    update :update do
      primary? true
      accept [:name, :description, :description_motivational, :karma_min]
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
      require_atomic? false
    end
  end

  validations do
    validate compare(:karma_min, greater_than: 0)
  end

end
