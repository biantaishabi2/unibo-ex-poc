# Workflow: website_lifecycle — 网站管理流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   update --> update
# ```
defmodule UniboV4.Ecommerce.WebSite do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Ecommerce,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "ecommerce_web_sites"
    repo UniboV4.Repo
  end

  graphql do
    type :ecommerce_web_site

    queries do
      get :get_ecommerce_web_site, :read
      list :list_ecommerce_web_sites, :read
    end

    mutations do
      create :create_ecommerce_web_site, :create
      update :update_ecommerce_web_site, :update
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
    attribute :domain_name, :string, public?: true
    attribute :default_lang_id, :uuid do
      allow_nil? false
      public? true
    end
    attribute :homepage_url, :string do
      default "/"
      public? true
    end
    attribute :favicon, :string, public?: true
    attribute :logo, :string, public?: true
    attribute :social_twitter, :string, public?: true
    attribute :social_facebook, :string, public?: true
    attribute :social_github, :string, public?: true
    attribute :social_linkedin, :string, public?: true
    attribute :social_youtube, :string, public?: true
    attribute :social_instagram, :string, public?: true
    attribute :social_tiktok, :string, public?: true
    attribute :google_analytics_key, :string, public?: true
    attribute :google_search_console, :string, public?: true
    attribute :plausible_shared_key, :string, public?: true
    attribute :cdn_activated, :boolean do
      default false
      public? true
    end
    attribute :cdn_url, :string, public?: true
    attribute :cdn_filters, :string, public?: true
    attribute :cookies_bar, :boolean do
      default false
      public? true
    end
    attribute :custom_code_head, :string, public?: true
    attribute :custom_code_footer, :string, public?: true
    attribute :is_active, :boolean do
      default true
      public? true
    end
    attribute :description, :string, public?: true
    attribute :prevent_zero_price_sale, :boolean do
      default false
      public? true
    end
    attribute :cart_abandoned_delay, :decimal do
      default 1.0
      public? true
    end
    attribute :show_line_subtotals_tax_selection, :atom do
      constraints one_of: [:tax_included, :tax_excluded]
      public? true
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  calculations do
    # TODO: 不支持的 calculation 表达式 :get_cdn_url
    # TODO: 不支持的 calculation 表达式 :image_url
    # TODO: 不支持的 calculation 表达式 :alternate_languages
    # TODO: 不支持的 calculation 表达式 :canonical_url
  end

  relationships do
    belongs_to :theme, UniboV4.Ecommerce.Theme do
      public? true
    end
    belongs_to :default_pricelist, UniboV4.Ecommerce.Pricelist do
      public? true
    end
    belongs_to :cart_recovery_mail_template, UniboV4.Ecommerce.MailTemplate do
      public? true
    end
    has_many :pages, UniboV4.Ecommerce.WebPage do
      public? true
      destination_attribute :website_id
    end
    has_many :menus, UniboV4.Ecommerce.Menu do
      public? true
      destination_attribute :website_id
    end
    belongs_to :company, UniboV4.Ecommerce.Company do
      public? true
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:site_code, :name, :domain_name, :description, :default_lang_id, :homepage_url, :prevent_zero_price_sale, :cart_abandoned_delay, :show_line_subtotals_tax_selection]
      validate present(:site_code)
      validate present(:name)
      # TODO: 不支持的 change effect auto_create_homepage
      # TODO: 不支持的 change effect auto_create_public_user
      # TODO: 不支持的 change effect format_domain
      # TODO: 不支持的 change effect scale_favicon
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
      accept [:name, :domain_name, :is_active, :description, :homepage_url, :favicon, :logo, :social_twitter, :social_facebook, :social_github, :social_linkedin, :social_youtube, :social_instagram, :social_tiktok, :google_analytics_key, :google_search_console, :plausible_shared_key, :cdn_activated, :cdn_url, :cdn_filters, :cookies_bar, :custom_code_head, :custom_code_footer, :prevent_zero_price_sale, :cart_abandoned_delay, :show_line_subtotals_tax_selection]
      # TODO: 不支持的 change effect auto_create_cookie_policy_page
      # TODO: 不支持的 change effect format_domain
      # TODO: 不支持的 change effect scale_favicon
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

end
