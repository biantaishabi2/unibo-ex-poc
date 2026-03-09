# Workflow: badge_lifecycle_flow — 勋章定义创建、更新与删除流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
#   destroy --> [*]
# ```
defmodule UniboExPoc.Gamification.Badge do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Gamification,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "勋章定义，支持4级授予权限控制和月度限额"
  end

  postgres do
    table "gamification_badges"
    repo UniboExPoc.Repo
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
      description "勋章名称"
    end
    attribute :active, :boolean do
      default true
      public? true
      description "是否启用"
    end
    attribute :description, :string do
      public? true
      description "勋章描述"
    end
    attribute :level, :atom do
      constraints one_of: [:bronze, :silver, :gold]
      default :bronze
      public? true
      description "勋章等级"
    end
    attribute :rule_auth, :atom do
      constraints one_of: [:everyone, :users, :having, :nobody]
      default :everyone
      public? true
      description "授予权限（所有人/指定用户/拥有特定勋章者/无人）"
    end
    attribute :rule_max, :boolean do
      default false
      public? true
      description "是否启用月度发送限制"
    end
    attribute :rule_max_number, :integer do
      default 0
      public? true
      description "每月限制数量"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  calculations do
    calculate :granted_count, :integer, {UniboExPoc.Gamification.Calculations.Badge.GrantedCount, []}
    calculate :granted_users_count, :integer, {UniboExPoc.Gamification.Calculations.Badge.GrantedUsersCount, []}
    calculate :stat_this_month, :integer, {UniboExPoc.Gamification.Calculations.Badge.StatThisMonth, []}
    calculate :remaining_sending, :integer, expr(remaining_sending_calc(rule_max, rule_max_number))
  end

  relationships do
    has_many :owner_ids, UniboExPoc.Gamification.BadgeUser do
      public? true
      destination_attribute :badge_id
    end
    many_to_many :rule_auth_user_ids, UniboExPoc.Gamification.Party do
      public? true
      through UniboExPoc.Gamification.BadgeAuthUserLink
      destination_attribute_on_join_resource :user_party_id
    end
    many_to_many :rule_auth_badge_ids, UniboExPoc.Gamification.Badge do
      public? true
      through UniboExPoc.Gamification.BadgeAuthBadgeLink
      source_attribute_on_join_resource :required_badge_id
      destination_attribute_on_join_resource :required_badge_id
    end
    has_many :translations, UniboExPoc.Gamification.BadgeTranslation, public?: true
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:name, :active, :description, :level, :rule_auth, :rule_max, :rule_max_number]
      validate present(:name)
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:name, :active, :description, :level, :rule_auth, :rule_max, :rule_max_number]
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
    archive_related [:owner_ids]
  end

end
