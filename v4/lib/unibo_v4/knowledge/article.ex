# Workflow: article_lifecycle — 文章生命周期与编辑协作流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> action_publish
#   create --> action_trash
#   create --> action_move
#   create --> action_copy
#   update --> update
#   update --> action_publish
#   update --> action_trash
#   update --> action_move
#   update --> action_copy
#   action_publish --> action_unpublish
#   action_publish --> action_archive
#   action_publish --> action_lock
#   action_unpublish --> action_publish
#   action_unpublish --> action_move
#   action_unpublish --> action_copy
#   action_unpublish --> action_trash
#   action_archive --> action_restore_state
#   action_restore_state --> action_publish
#   action_restore_state --> action_move
#   action_restore_state --> action_trash
#   action_trash --> action_restore_trash
#   action_restore_trash --> action_move
#   action_restore_trash --> action_publish
#   action_restore_trash --> action_archive
#   action_lock --> action_unlock
#   action_unlock --> update
#   action_unlock --> action_publish
#   action_unlock --> action_archive
#   action_move --> update
#   action_move --> action_publish
#   action_move --> action_archive
#   action_move --> action_trash
#   action_copy --> action_publish
#   action_copy --> action_move
# ```
defmodule UniboV4.Knowledge.Article do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Knowledge,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource],
    authorizers: [Ash.Policy.Authorizer],
    notifiers: [UniboV4.Knowledge.Article.Notifier]

  postgres do
    table "knowledge_articles"
    repo UniboV4.Repo
  end

  graphql do
    type :knowledge_article

    queries do
      get :get_knowledge_article, :read
      list :list_knowledge_articles, :read
    end

    mutations do
      create :create_create_knowledge_article, :create
      create :create_action_copy_knowledge_article, :action_copy
      update :update_knowledge_article, :update
      update :action_publish_knowledge_article, :action_publish
      update :action_unpublish_knowledge_article, :action_unpublish
      update :action_archive_knowledge_article, :action_archive
      update :action_restore_state_knowledge_article, :action_restore_state
      update :action_trash_knowledge_article, :action_trash
      update :action_restore_trash_knowledge_article, :action_restore_trash
      update :action_lock_knowledge_article, :action_lock
      update :action_unlock_knowledge_article, :action_unlock
      update :action_move_knowledge_article, :action_move
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
    end
    attribute :body, :string do
      default ""
      public? true
    end
    attribute :state, :atom do
      allow_nil? false
      constraints one_of: [:draft, :published, :archived]
      default :draft
      public? true
    end
    attribute :parent_id, :uuid, public?: true
    attribute :sequence, :integer do
      allow_nil? false
      default 0
      public? true
    end
    attribute :category, :atom do
      allow_nil? false
      constraints one_of: [:workspace, :shared, :private]
      default :private
      public? true
    end
    attribute :icon, :string, public?: true
    attribute :cover_image_id, :uuid, public?: true
    attribute :is_locked, :boolean do
      allow_nil? false
      default false
      public? true
    end
    attribute :is_template, :boolean do
      allow_nil? false
      default false
      public? true
    end
    attribute :active, :boolean do
      allow_nil? false
      default true
      public? true
    end
    attribute :trashed_date, :utc_datetime, public?: true
    attribute :last_edition_uid, :uuid, public?: true
    attribute :last_edition_date, :utc_datetime, public?: true
    attribute :locked_by, :uuid, public?: true
    attribute :locked_at, :utc_datetime, public?: true
    attribute :create_uid, :uuid do
      allow_nil? false
      public? true
    end
    attribute :write_uid, :uuid do
      allow_nil? false
      public? true
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  calculations do
    # TODO: 不支持的 calculation 表达式 :full_name
    # TODO: 不支持的 calculation 表达式 :root_article_id
    # TODO: 不支持的 calculation 表达式 :article_url
    # TODO: 不支持的 calculation 表达式 :body_short
    # TODO: 不支持的 calculation 表达式 :has_write_access
    # TODO: 不支持的 calculation 表达式 :has_read_access
    # TODO: 不支持的 calculation 表达式 :is_favorite
    calculate :version_count, :integer, expr(count(versions, query: [filter: expr(true)]))
    calculate :favorite_count, :integer, expr(count(favorites, query: [filter: expr(true)]))
  end

  relationships do
    belongs_to :parent, UniboV4.Knowledge.Article do
      public? true
    end
    has_many :children, UniboV4.Knowledge.Article do
      public? true
      destination_attribute :parent_id
    end
    has_many :members, UniboV4.Knowledge.ArticleMember do
      public? true
    end
    has_many :versions, UniboV4.Knowledge.ArticleVersion do
      public? true
    end
    has_many :favorites, UniboV4.Knowledge.Favorite do
      public? true
    end
    many_to_many :tags, UniboV4.Knowledge.Tag do
      public? true
      through UniboV4.Knowledge.ArticleTagLink
    end
    belongs_to :creator, UniboV4.Knowledge.User do
      public? true
      source_attribute :create_uid
    end
    belongs_to :last_writer, UniboV4.Knowledge.User do
      public? true
      source_attribute :write_uid
    end
    belongs_to :locker, UniboV4.Knowledge.User do
      public? true
      source_attribute :locked_by
    end
    belongs_to :last_editor, UniboV4.Knowledge.User do
      public? true
      source_attribute :last_edition_uid
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:name, :body, :parent_id, :sequence, :category, :icon, :cover_image_id, :is_template]
      argument :members, {:array, :map}, default: []
      change manage_relationship(:members, :members, type: :create)
      validate present(:name)
      change relate_actor(:create_uid)
      change relate_actor(:write_uid)
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
      accept [:name, :body, :sequence, :category, :icon, :cover_image_id, :is_template]
      argument :members, {:array, :map}, default: []
      change manage_relationship(:members, :members, on_lookup: :relate, on_no_match: :create, on_match: :update)
      # skipped: validate custom : (incompatible with bulk update atomic path)
      change relate_actor(:write_uid)
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
    update :action_publish do
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :state)
        if current == :draft do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :state, message: "must equal %{value}", vars: %{value: :draft}))
        end
      end
      # message: "只有草稿状态可以发布"
      # skipped: validate custom : (incompatible with bulk update atomic path)
      change relate_actor(:write_uid)
      change set_attribute(:state, :published)
      # TODO: 不支持的 change effect custom
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
    update :action_unpublish do
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :state)
        if current == :published do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :state, message: "must equal %{value}", vars: %{value: :published}))
        end
      end
      # message: "只有已发布状态可以撤销发布"
      # skipped: validate custom : (incompatible with bulk update atomic path)
      change relate_actor(:write_uid)
      change set_attribute(:state, :draft)
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
    update :action_archive do
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :state)
        if current == :published do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :state, message: "must equal %{value}", vars: %{value: :published}))
        end
      end
      # message: "只有已发布状态可以归档"
      # skipped: validate custom : (incompatible with bulk update atomic path)
      change relate_actor(:write_uid)
      change set_attribute(:state, :archived)
      # TODO: 不支持的 change effect custom
      # TODO: 不支持的 change effect custom
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
    update :action_restore_state do
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :state)
        if current == :archived do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :state, message: "must equal %{value}", vars: %{value: :archived}))
        end
      end
      # message: "只有已归档状态可以恢复"
      # skipped: validate custom : (incompatible with bulk update atomic path)
      change relate_actor(:write_uid)
      change set_attribute(:state, :draft)
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
    update :action_trash do
      accept []
      # skipped: validate custom : (incompatible with bulk update atomic path)
      # skipped: validate custom : (incompatible with bulk update atomic path)
      # skipped: validate custom : (incompatible with bulk update atomic path)
      change relate_actor(:write_uid)
      change set_attribute(:active, false)
      # TODO: 跨实体聚合表达式暂不支持
      # TODO: 不支持的 change effect custom
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
    update :action_restore_trash do
      accept []
      # skipped: validate custom : (incompatible with bulk update atomic path)
      # skipped: validate custom : (incompatible with bulk update atomic path)
      # skipped: validate custom : (incompatible with bulk update atomic path)
      change relate_actor(:write_uid)
      change set_attribute(:active, true)
      # TODO: 不支持的 change effect custom
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
    update :action_lock do
      accept []
      # skipped: validate custom : (incompatible with bulk update atomic path)
      change relate_actor(:write_uid)
      change set_attribute(:is_locked, true)
      change relate_actor(:locked_by)
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
    update :action_unlock do
      accept []
      # skipped: validate custom : (incompatible with bulk update atomic path)
      change relate_actor(:write_uid)
      change set_attribute(:is_locked, false)
      # TODO: 不支持的 change effect custom
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
    update :action_move do
      argument :new_parent_id, :uuid
      # skipped: validate custom : (incompatible with bulk update atomic path)
      # skipped: validate custom : (incompatible with bulk update atomic path)
      change relate_actor(:write_uid)
      # TODO: 不支持的 change effect custom
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
    create :action_copy do
      argument :source_article_id, :uuid, allow_nil?: false
      argument :members, {:array, :map}, default: []
      change manage_relationship(:members, :members, type: :create)
      validate present(:name)
      change relate_actor(:create_uid)
      change relate_actor(:write_uid)
      # TODO: 不支持的 change effect custom
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

  policies do
    policy action_type(:read) do
      authorize_if expr(check_access(data, actor, :read))
    end
    policy action_type(:update) do
      authorize_if expr(check_access(data, actor, :write))
    end
    policy action_type(:destroy) do
      authorize_if expr(check_access(data, actor, :owner))
    end
  end

end
