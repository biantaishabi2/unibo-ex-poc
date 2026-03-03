# Workflow: blog_post_lifecycle — 文章生命周期：草稿→发布→归档
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> publish
#   update --> publish
#   publish --> unpublish
#   publish --> archive
#   unpublish --> publish
#   unpublish --> archive
#   archive --> unarchive
#   unarchive --> publish
# ```
defmodule UniboV4.Blog.BlogPost do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Blog,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource],
    authorizers: [Ash.Policy.Authorizer],
    notifiers: [UniboV4.Blog.BlogPost.Notifier]

  postgres do
    table "blog_posts"
    repo UniboV4.Repo
  end

  graphql do
    type :blog_blog_post

    queries do
      get :get_blog_blog_post, :read
      list :list_blog_blog_posts, :read
    end

    mutations do
      create :create_blog_blog_post, :create
      update :update_blog_blog_post, :update
      update :publish_blog_blog_post, :publish
      update :unpublish_blog_blog_post, :unpublish
      update :archive_blog_blog_post, :archive
      update :unarchive_blog_blog_post, :unarchive
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
    end
    attribute :subtitle, :string, public?: true
    attribute :content, :string, public?: true
    attribute :cover_properties, :string, public?: true
    attribute :is_published, :boolean do
      default false
      public? true
    end
    attribute :published_date, :utc_datetime, public?: true
    attribute :active, :boolean do
      default true
      public? true
    end
    attribute :visits, :integer do
      default 0
      public? true
    end
    attribute :author_avatar, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  calculations do
    # TODO: 不支持的 calculation 表达式 :post_date
    # TODO: 不支持的 calculation 表达式 :teaser
    # TODO: 不支持的 calculation 表达式 :website_url
  end

  relationships do
    belongs_to :blog, UniboV4.Blog.Blog do
      public? true
      allow_nil? false
    end
    belongs_to :author, UniboV4.Blog.User do
      public? true
    end
    has_many :tags, UniboV4.Blog.BlogTag do
      public? true
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:name, :subtitle, :content, :cover_properties]
      argument :teaser, :string
      argument :blog_id, :uuid, allow_nil?: false
      change manage_relationship(:blog_id, :blog, type: :append, on_lookup: :relate)
      validate present(:name)
      change relate_actor(:author_id)
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
      accept [:name, :subtitle, :content, :cover_properties]
      argument :teaser, :string
      argument :tag_ids, :string
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
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :is_published)
        if current == false do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :is_published, message: "must equal %{value}", vars: %{value: false}))
        end
      end
      # message: "文章已经处于发布状态"
      change set_attribute(:is_published, true)
      # TODO: 跨实体聚合表达式暂不支持
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
        current = Ash.Changeset.get_attribute(changeset, :is_published)
        if current == true do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :is_published, message: "must equal %{value}", vars: %{value: true}))
        end
      end
      # message: "文章未发布，无法取消发布"
      change set_attribute(:is_published, false)
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
    update :archive do
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :active)
        if current == true do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :active, message: "must equal %{value}", vars: %{value: true}))
        end
      end
      # message: "文章已经处于归档状态"
      change set_attribute(:active, false)
      change set_attribute(:is_published, false)
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
    update :unarchive do
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :active)
        if current == false do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :active, message: "must equal %{value}", vars: %{value: false}))
        end
      end
      # message: "文章未归档，无法取消归档"
      change set_attribute(:active, true)
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

  policies do
    policy action_type(:read) do
      authorize_if expr(is_published == true or role in [:designer, :admin])
    end
  end

end
