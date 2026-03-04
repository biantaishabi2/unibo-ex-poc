# Workflow: blog_maintain_flow — 博客维护流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> archive
#   update --> [*]
#   archive --> [*]
# ```
defmodule UniboV4.Blog.Blog do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Blog,
    data_layer: AshPostgres.DataLayer,
    notifiers: [UniboV4.Blog.Blog.Notifier]

  postgres do
    table "blog_blogs"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
    end
    attribute :subtitle, :string, public?: true
    attribute :active, :boolean do
      default true
      public? true
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  calculations do
    calculate :blog_post_count, :integer, expr(count(blog_posts, query: [filter: expr(true)]))
  end

  relationships do
    has_many :blog_posts, UniboV4.Blog.BlogPost do
      public? true
    end
    belongs_to :website, UniboV4.Blog.Website do
      public? true
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:name, :subtitle]
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
      # TODO: 不支持的 change effect cascade
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

end
