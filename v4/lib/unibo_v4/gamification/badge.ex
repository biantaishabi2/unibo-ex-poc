# Workflow: badge_lifecycle_flow — 勋章定义创建、更新与删除流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
#   destroy --> [*]
# ```
defmodule UniboV4.Gamification.Badge do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Gamification,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "gamification_badges"
    repo UniboV4.Repo
  end

  graphql do
    type :gamification_badge

    queries do
      get :get_gamification_badge, :read
      list :list_gamification_badges, :read
    end

    mutations do
      create :create_gamification_badge, :create
      update :update_gamification_badge, :update
      destroy :delete_gamification_badge, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
    end
    attribute :active, :boolean do
      default true
      public? true
    end
    attribute :description, :string, public?: true
    attribute :level, :atom do
      constraints one_of: [:bronze, :silver, :gold]
      default :bronze
      public? true
    end
    attribute :rule_auth, :atom do
      constraints one_of: [:everyone, :users, :having, :nobody]
      default :everyone
      public? true
    end
    attribute :rule_max, :boolean do
      default false
      public? true
    end
    attribute :rule_max_number, :integer do
      default 0
      public? true
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  calculations do
    # TODO: 不支持的 calculation 表达式 :granted_count
    # TODO: 不支持的 calculation 表达式 :granted_users_count
    # TODO: 不支持的 calculation 表达式 :stat_this_month
    # TODO: 不支持的 calculation 表达式 :remaining_sending
  end

  relationships do
    has_many :owner_ids, UniboV4.Gamification.BadgeUser do
      public? true
      destination_attribute :badge_id
    end
    many_to_many :rule_auth_user_ids, UniboV4.Gamification.ResUser do
      public? true
      through UniboV4.Gamification.BadgeAuthUserLink
    end
    many_to_many :rule_auth_badge_ids, UniboV4.Gamification.Badge do
      public? true
      through UniboV4.Gamification.BadgeAuthBadgeLink
    end
    has_many :translations, UniboV4.Gamification.BadgeTranslation, public?: true
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:name, :active, :description, :level, :rule_auth, :rule_max, :rule_max_number]
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
      accept [:name, :active, :description, :level, :rule_auth, :rule_max, :rule_max_number]
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

end
