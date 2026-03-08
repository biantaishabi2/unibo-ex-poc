# Workflow: website_lifecycle — 网站管理流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   update --> update
# ```
defmodule UniboExPoc.Website.WebSite do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Website,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource]

  resource do
    description "网站"
  end

  postgres do
    table "website_web_sites"
    repo UniboExPoc.Repo
  end

  graphql do
    type :website_web_site

    queries do
      get :get_website_web_site, :read
      list :list_website_web_sites, :read
    end

    mutations do
      create :create_website_web_site, :create
      update :update_website_web_site, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :site_code, :string do
      allow_nil? false
      public? true
    end
    attribute :name, :string do
      allow_nil? false
      public? true
    end
    attribute :domain_name, :string do
      public? true
      description "域名（SQL 唯一约束，写入时自动 HTTPS + 去尾斜杠）"
    end
    attribute :default_lang_id, :uuid do
      allow_nil? false
      public? true
      description "默认语言"
    end
    attribute :homepage_url, :string do
      default "/"
      public? true
      description "首页 URL"
    end
    attribute :favicon, :string do
      public? true
      description "网站图标，上传时自动缩放至 256x256 ICO 格式"
    end
    attribute :logo, :string do
      public? true
      description "网站 Logo"
    end
    attribute :social_twitter, :string do
      public? true
      description "Twitter 账号"
    end
    attribute :social_facebook, :string do
      public? true
      description "Facebook 链接"
    end
    attribute :social_github, :string do
      public? true
      description "GitHub 链接"
    end
    attribute :social_linkedin, :string do
      public? true
      description "LinkedIn 链接"
    end
    attribute :social_youtube, :string do
      public? true
      description "YouTube 链接"
    end
    attribute :social_instagram, :string do
      public? true
      description "Instagram 链接"
    end
    attribute :social_tiktok, :string do
      public? true
      description "TikTok 链接"
    end
    attribute :google_analytics_key, :string do
      public? true
      description "Google Analytics 追踪码"
    end
    attribute :google_search_console, :string do
      public? true
      description "Google Search Console 验证码"
    end
    attribute :plausible_shared_key, :string do
      public? true
      description "Plausible 分析密钥"
    end
    attribute :cdn_activated, :boolean do
      default false
      public? true
      description "CDN 开关"
    end
    attribute :cdn_url, :string do
      public? true
      description "CDN 基础 URL"
    end
    attribute :cdn_filters, :string do
      public? true
      description "CDN URL 匹配正则"
    end
    attribute :cookies_bar, :boolean do
      default false
      public? true
      description "Cookie 弹窗开关"
    end
    attribute :custom_code_head, :string do
      public? true
      description "自定义 head 脚本"
    end
    attribute :custom_code_footer, :string do
      public? true
      description "自定义 footer 脚本"
    end
    attribute :is_active, :boolean do
      default true
      public? true
    end
    attribute :description, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  calculations do
    calculate :get_cdn_url, :string, expr(cdn_url)
    calculate :image_url, :string, expr(cdn_url)
    calculate :alternate_languages, :string, expr(name)
    calculate :canonical_url, :string, expr(homepage_url)
  end

  relationships do
    has_many :pages, UniboExPoc.Website.WebPage do
      public? true
      source_attribute :company_party_id
      destination_attribute :website_id
    end
    has_many :menus, UniboExPoc.Website.Menu do
      public? true
      source_attribute :company_party_id
      destination_attribute :website_id
    end
    belongs_to :company, UniboExPoc.Website.Party do
      public? true
      source_attribute :company_party_id
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:site_code, :name, :domain_name, :description, :default_lang_id, :homepage_url]
      argument :company_id, :uuid
      validate present(:site_code)
      validate present(:name)
      change UniboExPoc.Website.Changes.WebSite.CreateCall1
      change UniboExPoc.Website.Changes.WebSite.CreateCall2
      change UniboExPoc.Website.Changes.WebSite.CreateCall4
      change UniboExPoc.Website.Changes.WebSite.CreateCall5
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
      accept [:name, :domain_name, :is_active, :description, :homepage_url, :favicon, :logo, :social_twitter, :social_facebook, :social_github, :social_linkedin, :social_youtube, :social_instagram, :social_tiktok, :google_analytics_key, :google_search_console, :plausible_shared_key, :cdn_activated, :cdn_url, :cdn_filters, :cookies_bar, :custom_code_head, :custom_code_footer]
      change UniboExPoc.Website.Changes.WebSite.UpdateCall3
      change UniboExPoc.Website.Changes.WebSite.UpdateCall4
      change UniboExPoc.Website.Changes.WebSite.UpdateCall5
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

  identities do
    identity :unique_site_code, [:site_code]
    identity :unique_domain_name, [:domain_name]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
