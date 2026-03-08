# Workflow: blog_maintain_flow — 博客维护流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> archive
#   update --> [*]
#   archive --> [*]
# ```
defmodule UniboExPoc.Blog.Blog do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Blog,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource],
    notifiers: [UniboExPoc.Blog.Blog.Notifier]

  resource do
    description "博客容器（对应 Odoo blog.blog）"
  end

  postgres do
    table "blog_blogs"
    repo UniboExPoc.Repo
  end

  graphql do
    type :blog_blog

    queries do
      get :get_blog_blog, :read
      list :list_blog_blogs, :read
    end

    mutations do
      create :create_blog_blog, :create
      update :update_blog_blog, :update
      update :archive_blog_blog, :archive
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
      description "博客名称"
    end
    attribute :subtitle, :string do
      public? true
      description "副标题"
    end
    attribute :active, :boolean do
      default true
      public? true
      description "归档标记；置 False 级联归档所有文章"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  calculations do
    calculate :blog_post_count, :integer, expr(count(blog_posts, query: [filter: expr(true)]))
  end

  relationships do
    has_many :blog_posts, UniboExPoc.Blog.BlogPost do
      public? true
    end
    belongs_to :website, UniboExPoc.Blog.WebSite do
      public? true
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:name, :subtitle, :website_id]
      validate present(:name)
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
      accept [:name, :subtitle, :active]
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
      description "归档博客，级联归档所有文章"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :active)
        if current == true do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :active, message: "must equal %{value}", vars: %{value: true}))
        end
      end
      # message: "只有活跃状态的博客可以归档"
      change set_attribute(:active, false)
      # cascade_destroy — 缺少 field，跳过
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

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
