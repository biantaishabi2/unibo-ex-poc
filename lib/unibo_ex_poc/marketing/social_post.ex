# Workflow: social_post_lifecycle — 社交帖子生命周期
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> publish_now
#   create --> schedule
#   update --> publish_now
#   update --> schedule
#   publish_now --> sync_stats
#   schedule --> sync_stats
#   sync_stats --> [*]
# ```
defmodule UniboExPoc.Marketing.SocialPost do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Marketing,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource],
    notifiers: [UniboExPoc.Marketing.SocialPost.Notifier]

  resource do
    description "社交媒体帖文"
  end

  postgres do
    table "marketing_social_posts"
    repo UniboExPoc.Repo
  end

  graphql do
    type :marketing_social_post

    queries do
      get :get_marketing_social_post, :read
      list :list_marketing_social_posts, :read
    end

    mutations do
      create :create_marketing_social_post, :create
      update :update_marketing_social_post, :update
      update :publish_now_marketing_social_post, :publish_now
      update :schedule_marketing_social_post, :schedule
      update :sync_stats_marketing_social_post, :sync_stats
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :content, :string do
      allow_nil? false
      public? true
      description "帖文内容"
    end
    attribute :status, :atom do
      constraints one_of: [:draft, :scheduled, :posting, :posted]
      default :draft
      public? true
    end
    attribute :scheduled_date, :utc_datetime do
      public? true
      description "计划发布时间（仅 scheduled 状态）"
    end
    attribute :published_date, :utc_datetime do
      public? true
      description "实际发布时间"
    end
    attribute :media_ids, {:array, :string} do
      public? true
      description "附件/媒体文件列表"
    end
    attribute :platform_specific, :string do
      public? true
      description "平台特定内容（YouTube 标题/描述、Instagram 图片等）"
    end
    attribute :utm_source, :string do
      public? true
      description "UTM 来源标记"
    end
    attribute :utm_medium, :string do
      default "social"
      public? true
      description "UTM 媒介标记"
    end
    attribute :utm_campaign, :string do
      public? true
      description "UTM 活动标记"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :campaign, UniboExPoc.Marketing.Campaign do
      public? true
    end
    many_to_many :accounts, UniboExPoc.Marketing.SocialAccount do
      public? true
      through UniboExPoc.Marketing.SocialPostAccountLink
    end
    belongs_to :created_by, UniboExPoc.Marketing.Party do
      public? true
      source_attribute :created_by_party_id
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:content, :media_ids, :platform_specific, :utm_source, :utm_medium, :utm_campaign]
      argument :campaign_id, :uuid
      argument :account_ids, {:array, :string}
      validate present(:content)
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:content, :media_ids, :platform_specific, :scheduled_date]
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :publish_now do
      description "立即发布（draft → posting → posted）"
      accept []
      # skipped: validate present :content (incompatible with bulk update atomic path)
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :draft do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :draft}))
        end
      end
      # message: "只有草稿状态可以发布或排期"
      # skipped: validate present : (incompatible with bulk update atomic path)
      change set_attribute(:status, :posting)
      change UniboExPoc.Marketing.Changes.SocialPost.PublishNowCall2
      change set_attribute(:status, :posted)
      change set_attribute(:published_date, &DateTime.utc_now/0)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :schedule do
      description "定时发布（draft → scheduled）"
      accept [:scheduled_date]
      # skipped: validate present :content (incompatible with bulk update atomic path)
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :draft do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :draft}))
        end
      end
      # message: "只有草稿状态可以发布或排期"
      # skipped: validate present : (incompatible with bulk update atomic path)
      # skipped: validate compare :schedule_date (incompatible with bulk update atomic path)
      change set_attribute(:status, :scheduled)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :sync_stats do
      description "同步各平台帖文统计数据"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :posted do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :posted}))
        end
      end
      # message: "只有已发布状态可以同步统计"
      change UniboExPoc.Marketing.Changes.SocialPost.SyncStatsCall7
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
