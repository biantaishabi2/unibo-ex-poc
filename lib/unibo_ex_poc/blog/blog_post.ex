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
defmodule UniboExPoc.Blog.BlogPost do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Blog,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource],
    authorizers: [Ash.Policy.Authorizer],
    notifiers: [UniboExPoc.Blog.BlogPost.Notifier]

  resource do
    description "博客文章，支持 Draft→Published→Archived 生命周期"
  end

  postgres do
    table "blog_posts"
    repo UniboExPoc.Repo
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
      description "文章标题"
    end
    attribute :subtitle, :string do
      public? true
      description "副标题，用于 OG description"
    end
    attribute :content, :string do
      public? true
      description "正文 HTML"
    end
    attribute :cover_properties, :string do
      public? true
      description "封面图属性（背景图 URL、resize 参数等）"
    end
    attribute :is_published, :boolean do
      default false
      public? true
      description "发布标记"
    end
    attribute :published_date, :utc_datetime do
      public? true
      description "首次发布时间"
    end
    attribute :active, :boolean do
      default true
      public? true
      description "归档标记"
    end
    attribute :visits, :integer do
      default 0
      public? true
      description "浏览次数"
    end
    attribute :author_avatar, :string do
      public? true
      description "作者头像 image_128（related 字段）"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  calculations do
    calculate :post_date, :utc_datetime, {UniboExPoc.Blog.Calculations.BlogPost.PostDate, []}
    calculate :teaser, :string, expr(strip_tags_truncate(content, 200))
    calculate :website_url, :string, expr(format("/blog/{}/{}", blog.name, name))
  end

  relationships do
    belongs_to :blog, UniboExPoc.Blog.Blog do
      public? true
      allow_nil? false
    end
    belongs_to :author, UniboExPoc.Blog.Party do
      public? true
      source_attribute :author_party_id
    end
    has_many :tags, UniboExPoc.Blog.BlogTag do
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
      # relate_actor :author_id — 无对应关系，跳过
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:name, :subtitle, :content, :cover_properties]
      argument :teaser, :string
      argument :tag_ids, :string
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :publish do
      description "发布文章"
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
      change UniboExPoc.Blog.Changes.BlogPost.ComputePublishedDate
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :unpublish do
      description "取消发布，回到草稿状态"
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
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :archive do
      description "归档文章"
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
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :unarchive do
      description "取消归档，恢复为草稿状态"
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
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  policies do
    policy action_type(:read) do
      authorize_if expr(is_published == true or actor.role in [:designer, :admin])
    end
    policy always() do
      authorize_if always()
    end
  end

end
