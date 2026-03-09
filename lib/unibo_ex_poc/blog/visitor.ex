# Workflow: visitor_lifecycle — 访客生命周期
# ```mermaid
# stateDiagram-v2
#   [*] --> upsert
#   upsert --> track_visit
#   track_visit --> track_visit
#   track_visit --> merge
#   track_visit --> cleanup
#   merge --> [*]
#   cleanup --> [*]
# ```
defmodule UniboExPoc.Blog.Visitor do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Blog,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "网站访客追踪，支持匿名哈希标识与访问节流"
  end

  postgres do
    table "blog_visitors"
    repo UniboExPoc.Repo
  end

  graphql do
    type :blog_visitor

    queries do
      get :get_blog_visitor, :read
      list :list_blog_visitors, :read
    end

    mutations do
      create :create_upsert_blog_visitor, :upsert
      update :track_visit_blog_visitor, :track_visit
      update :merge_blog_visitor, :merge
      destroy :delete_cleanup_blog_visitor, :cleanup
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :access_token, :string do
      allow_nil? false
      public? true
      description "访客标识：已登录=partner_id；匿名=SHA1(IP+UA+Session)"
    end
    attribute :visit_count, :integer do
      default 0
      public? true
      description "访问次数（距上次 >= 8h 才递增）"
    end
    attribute :last_connection_datetime, :utc_datetime do
      public? true
      description "最后活跃时间"
    end
    attribute :country_id, :uuid do
      public? true
      description "国家"
    end
    attribute :lang_id, :uuid do
      public? true
      description "语言"
    end
    attribute :timezone, :string do
      public? true
      description "时区：优先 cookie tz，其次用户设置"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  calculations do
    calculate :is_connected, :boolean, expr(diff_minutes(now(), last_connection_datetime) <= 5)
    calculate :visitor_page_count, :integer, expr(count(website_tracks, query: [filter: expr(true)]))
    calculate :time_since_last_action, :string, expr(human_readable_diff(now(), last_connection_datetime))
  end

  relationships do
    belongs_to :partner, UniboExPoc.Blog.Party do
      public? true
      source_attribute :partner_party_id
    end
    has_many :website_tracks, UniboExPoc.Blog.WebsiteTrack do
      public? true
    end
    belongs_to :last_visited_page, UniboExPoc.Website.WebPage do
      public? true
    end
  end

  actions do
    defaults [:read]
    create :upsert do
      description "创建或更新访客记录"
      accept [:access_token, :country_id, :lang_id, :timezone]
      argument :partner_id, :uuid
      validate present(:access_token)
      change set_attribute(:id, expr(id))
    end
    update :track_visit do
      description "记录一次访问，受 8 小时节流规则约束"
      primary? true
      accept []
      change set_attribute(:visit_count, expr((visit_count + 1)))
      change UniboExPoc.Blog.Changes.Visitor.ComputeLastConnectionDatetime
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :merge do
      description "用户登录时合并匿名访客数据到已认证访客记录"
      argument :target_visitor_id, :uuid, allow_nil?: false
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    destroy :cleanup do
      description "定时清理 60+ 天无活动且无 partner 关联的访客"
      change set_attribute(:id, expr(id))
    end
  end

  identities do
    identity :unique_access_token, [:access_token]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
    archive_related [:website_tracks]
  end

end
