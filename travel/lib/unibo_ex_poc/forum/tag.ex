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
defmodule UniboExPoc.Forum.Tag do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Forum,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "论坛标签，用于帖子分类"
  end

  postgres do
    table "forum_tags"
    repo UniboExPoc.Repo
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
      description "标签名称"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  calculations do
    calculate :posts_count, :integer, expr(count(posts, query: [filter: expr(true)]))
  end

  relationships do
    belongs_to :forum, UniboExPoc.Forum.Forum do
      public? true
      allow_nil? false
    end
    many_to_many :posts, UniboExPoc.Forum.Post do
      public? true
      through UniboExPoc.Forum.PostTagLink
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
      validate present(:)
      # message: "Karma 不足，无法创建标签"
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

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
  end

end
