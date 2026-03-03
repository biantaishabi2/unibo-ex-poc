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
defmodule UniboV4.Ecommerce.WebPage do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Ecommerce,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource],
    notifiers: [UniboV4.Ecommerce.WebPage.Notifier]

  postgres do
    table "ecommerce_web_pages"
    repo UniboV4.Repo
  end

  graphql do
    type :ecommerce_web_page

    queries do
      get :get_ecommerce_web_page, :read
      list :list_ecommerce_web_pages, :read
    end

    mutations do
      create :create_create_ecommerce_web_page, :create
      create :create_clone_page_ecommerce_web_page, :clone_page
      update :update_ecommerce_web_page, :update
      update :publish_ecommerce_web_page, :publish
      update :unpublish_ecommerce_web_page, :unpublish
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :url, :string do
      allow_nil? false
      public? true
    end
    attribute :name, :string do
      allow_nil? false
      public? true
    end
    attribute :view_id, :uuid do
      allow_nil? false
      public? true
    end
    attribute :website_published, :boolean do
      default false
      public? true
    end
    attribute :date_publish, :utc_datetime, public?: true
    attribute :website_indexed, :boolean do
      default true
      public? true
    end
    attribute :header_overlay, :boolean do
      default false
      public? true
    end
    attribute :header_color, :string, public?: true
    attribute :header_visible, :boolean do
      default true
      public? true
    end
    attribute :footer_visible, :boolean do
      default true
      public? true
    end
    attribute :visibility, :atom do
      constraints one_of: [:public, :password, :restricted_group]
      default :public
      public? true
    end
    attribute :visibility_password, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  calculations do
    # TODO: 不支持的 calculation 表达式 :is_visible
    # TODO: 不支持的 calculation 表达式 :is_homepage
    # TODO: 不支持的 calculation 表达式 :search_priority
  end

  relationships do
    belongs_to :website, UniboV4.Ecommerce.WebSite do
      public? true
    end
    has_many :menus, UniboV4.Ecommerce.Menu do
      public? true
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
      # TODO: 不支持的 action 内校验规则 custom
      # TODO: 不支持的 change effect slugify_url
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
      accept [:url, :name, :website_published, :date_publish, :website_indexed, :header_overlay, :header_color, :header_visible, :footer_visible, :visibility, :visibility_password]
      # skipped: validate custom : (incompatible with bulk update atomic path)
      # TODO: 不支持的 change effect slugify_url
      # TODO: 不支持的 change effect create_redirect
      # TODO: 不支持的 change effect sync_menu_url
      # TODO: 不支持的 change effect sync_homepage
      # TODO: 不支持的 change effect cow_branch
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
    update :publish do
      accept []
      # skipped: validate custom : (incompatible with bulk update atomic path)
      change set_attribute(:website_published, true)
      # TODO: 不支持的 change effect slugify_url
      # TODO: 不支持的 change effect create_redirect
      # TODO: 不支持的 change effect sync_menu_url
      # TODO: 不支持的 change effect sync_homepage
      # TODO: 不支持的 change effect cow_branch
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
    update :unpublish do
      accept []
      # skipped: validate custom : (incompatible with bulk update atomic path)
      change set_attribute(:website_published, false)
      # TODO: 不支持的 change effect slugify_url
      # TODO: 不支持的 change effect create_redirect
      # TODO: 不支持的 change effect sync_menu_url
      # TODO: 不支持的 change effect sync_homepage
      # TODO: 不支持的 change effect cow_branch
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
    create :clone_page do
      accept [:url, :name]
      argument :website_id, :uuid
      validate present(:url)
      validate present(:name)
      # TODO: 不支持的 action 内校验规则 custom
      # TODO: 不支持的 change effect slugify_url
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
    end
  end

end
