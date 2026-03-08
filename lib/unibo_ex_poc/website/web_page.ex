# Workflow: page_lifecycle — 网页生命周期
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> publish
#   update --> update
#   update --> publish
#   update --> unpublish
#   update --> clone_page
#   publish --> update
#   publish --> unpublish
#   unpublish --> update
#   unpublish --> publish
#   clone_page --> update
#   clone_page --> publish
# ```
defmodule UniboV4.Website.WebPage do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Website,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource],
    notifiers: [UniboV4.Website.WebPage.Notifier]

  resource do
    description "网站静态页面，支持 URL slugification 与定时发布"
  end

  postgres do
    table "website_web_pages"
    repo UniboV4.Repo
  end

  graphql do
    type :website_web_page

    queries do
      get :get_website_web_page, :read
      list :list_website_web_pages, :read
    end

    mutations do
      create :create_create_website_web_page, :create
      create :create_clone_page_website_web_page, :clone_page
      update :update_website_web_page, :update
      update :publish_website_web_page, :publish
      update :unpublish_website_web_page, :unpublish
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :url, :string do
      allow_nil? false
      public? true
      description "页面 URL（网站内唯一）"
    end
    attribute :name, :string do
      allow_nil? false
      public? true
      description "页面名称"
    end
    attribute :view_id, :uuid do
      allow_nil? false
      public? true
      description "关联 ir.ui.view（级联删除）"
    end
    attribute :website_published, :boolean do
      default false
      public? true
      description "发布状态"
    end
    attribute :date_publish, :utc_datetime do
      public? true
      description "定时发布时间"
    end
    attribute :website_indexed, :boolean do
      default true
      public? true
      description "搜索引擎索引开关"
    end
    attribute :header_overlay, :boolean do
      default false
      public? true
      description "页头覆盖模式"
    end
    attribute :header_color, :string do
      public? true
      description "页头颜色"
    end
    attribute :header_visible, :boolean do
      default true
      public? true
      description "页头可见"
    end
    attribute :footer_visible, :boolean do
      default true
      public? true
      description "页脚可见"
    end
    attribute :visibility, :atom do
      constraints one_of: [:public, :password, :restricted_group]
      default :public
      public? true
      description "可见性控制"
    end
    attribute :visibility_password, :string do
      public? true
      description "密码保护时的密码"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  calculations do
    calculate :is_visible, :boolean, expr((website_published == true and (date_publish == nil or date_publish <= now())))
    calculate :is_homepage, :boolean, expr(url == website.homepage_url)
    calculate :search_priority, :integer, expr(count(menus, query: [filter: expr(true)]))
  end

  relationships do
    belongs_to :website, UniboV4.Website.WebSite do
      public? true
    end
    has_many :menus, UniboV4.Website.Menu do
      public? true
      source_attribute :website_id
      destination_attribute :page_id
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:url, :name, :view_id, :website_published, :date_publish, :website_indexed, :header_overlay, :header_color, :header_visible, :footer_visible, :visibility, :visibility_password]
      argument :website_id, :uuid
      validate present(:url)
      validate present(:name)
      # validation: url_unique_per_website — URL 在同一 website_id 内必须唯一
      change UniboV4.Website.Changes.WebPage.CreateCall3
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:url, :name, :website_published, :date_publish, :website_indexed, :header_overlay, :header_color, :header_visible, :footer_visible, :visibility, :visibility_password]
      # skipped: validate custom : (incompatible with bulk update atomic path)
      change UniboV4.Website.Changes.WebPage.UpdateCall3
      change UniboV4.Website.Changes.WebPage.UpdateCall4
      change UniboV4.Website.Changes.WebPage.UpdateCall5
      change UniboV4.Website.Changes.WebPage.UpdateCall6
      change UniboV4.Website.Changes.WebPage.UpdateCall7
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :publish do
      description "发布页面"
      accept []
      # skipped: validate custom : (incompatible with bulk update atomic path)
      change set_attribute(:website_published, true)
      change UniboV4.Website.Changes.WebPage.PublishCall3
      change UniboV4.Website.Changes.WebPage.PublishCall4
      change UniboV4.Website.Changes.WebPage.PublishCall5
      change UniboV4.Website.Changes.WebPage.PublishCall6
      change UniboV4.Website.Changes.WebPage.PublishCall7
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :unpublish do
      description "取消发布"
      accept []
      # skipped: validate custom : (incompatible with bulk update atomic path)
      change set_attribute(:website_published, false)
      change UniboV4.Website.Changes.WebPage.UnpublishCall3
      change UniboV4.Website.Changes.WebPage.UnpublishCall4
      change UniboV4.Website.Changes.WebPage.UnpublishCall5
      change UniboV4.Website.Changes.WebPage.UnpublishCall6
      change UniboV4.Website.Changes.WebPage.UnpublishCall7
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    create :clone_page do
      description "克隆页面（不支持跨网站菜单克隆）"
      accept [:url, :name]
      argument :website_id, :uuid
      validate present(:url)
      validate present(:name)
      # validation: url_unique_per_website — URL 在同一 website_id 内必须唯一
      change UniboV4.Website.Changes.WebPage.ClonePageCall3
      change set_attribute(:id, expr(id))
    end
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
