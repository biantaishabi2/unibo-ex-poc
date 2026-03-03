# Workflow: tag_management — 标签管理流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> destroy
#   update --> update
#   update --> destroy
#   destroy --> [*]
# ```
defmodule UniboV4.Forum.Tag do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Forum,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "forum_tags"
    repo UniboV4.Repo
  end

  graphql do
    type :forum_tag

    queries do
      get :get_forum_tag, :read
      list :list_forum_tags, :read
    end

    mutations do
      create :create_forum_tag, :create
      update :update_forum_tag, :update
      destroy :delete_forum_tag, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  calculations do
    calculate :posts_count, :integer, expr(count(posts, query: [filter: expr(true)]))
  end

  relationships do
    belongs_to :forum, UniboV4.Forum.Forum do
      public? true
      allow_nil? false
    end
    many_to_many :posts, UniboV4.Forum.Post do
      public? true
      through UniboV4.Forum.PostTagLink
    end
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:name]
      argument :forum_id, :uuid, allow_nil?: false
      change manage_relationship(:forum_id, :forum, type: :append, on_lookup: :relate)
      validate present(:name)
      # TODO: 不支持的 action 内校验规则 custom
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
      accept [:name]
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
    identity :unique_tag_name_per_forum, [:forum_id, :name]
  end

end
