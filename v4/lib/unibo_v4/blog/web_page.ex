# Workflow: webpage_lifecycle — 网站页面生命周期
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> publish
#   update --> publish
#   publish --> unpublish
#   unpublish --> publish
# ```
defmodule UniboV4.Blog.WebPage do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Blog,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "blog_web_pages"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :url, :string do
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
    attribute :header_visible, :boolean do
      default true
      public? true
    end
    attribute :footer_visible, :boolean do
      default true
      public? true
    end
    attribute :header_overlay, :boolean do
      default false
      public? true
    end
    attribute :header_color, :string, public?: true
    attribute :header_text_color, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  calculations do
    # TODO: 不支持的 calculation 表达式 :is_visible
    # TODO: 不支持的 calculation 表达式 :is_homepage
    # TODO: 不支持的 calculation 表达式 :is_in_menu
  end

  relationships do
    belongs_to :website, UniboV4.Blog.Website do
      public? true
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:url, :website_indexed, :header_visible, :footer_visible, :header_overlay, :header_color, :header_text_color]
      validate present(:url)
      # TODO: 不支持的 change effect slugify
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
      accept [:url, :website_indexed, :header_visible, :footer_visible, :header_overlay, :header_color, :header_text_color]
      # TODO: 不支持的 change effect slugify
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
      argument :date_publish, :utc_datetime
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :website_published)
        if current == false do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :website_published, message: "must equal %{value}", vars: %{value: false}))
        end
      end
      # message: "页面已经处于发布状态"
      change set_attribute(:website_published, true)
      # TODO: 不支持的 change effect slugify
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
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :website_published)
        if current == true do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :website_published, message: "must equal %{value}", vars: %{value: true}))
        end
      end
      # message: "页面未发布，无法取消发布"
      change set_attribute(:website_published, false)
      # TODO: 不支持的 change effect slugify
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
    identity :unique_url, [:url]
  end

end
