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
defmodule UniboExPoc.Knowledge.Article do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Knowledge,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource],
    authorizers: [Ash.Policy.Authorizer],
    notifiers: [UniboExPoc.Knowledge.Article.Notifier]

  resource do
    description "知识库文章，支持树形层级、状态机、软删除、锁定编辑"
  end

  postgres do
    table "knowledge_articles"
    repo UniboExPoc.Repo
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
      description "文章标题"
    end
    attribute :body, :string do
      default ""
      public? true
      description "富文本正文（HTML 或 JSONB）"
    end
    attribute :state, :atom do
      allow_nil? false
      constraints one_of: [:draft, :published, :archived]
      default :draft
      public? true
      description "生命周期状态"
    end
    attribute :sequence, :integer do
      allow_nil? false
      default 0
      public? true
      description "同级排序序号"
    end
    attribute :category, :atom do
      allow_nil? false
      constraints one_of: [:workspace, :shared, :private]
      default :private
      public? true
      description "分类决定默认权限策略"
    end
    attribute :icon, :string do
      public? true
      description "文章图标"
    end
    attribute :cover_image_id, :uuid do
      public? true
      description "封面图片（FK → Attachment）"
    end
    attribute :is_locked, :boolean do
      allow_nil? false
      default false
      public? true
      description "是否锁定编辑"
    end
    attribute :is_template, :boolean do
      allow_nil? false
      default false
      public? true
      description "是否为模板"
    end
    attribute :active, :boolean do
      allow_nil? false
      default true
      public? true
      description "软删除标志（false = 回收站）"
    end
    attribute :trashed_date, :utc_datetime do
      public? true
      description "移入回收站时间，用于90天自动清理"
    end
    attribute :last_edition_date, :utc_datetime do
      public? true
      description "最近一次 body 变更时间"
    end
    attribute :locked_at, :utc_datetime do
      public? true
      description "锁定开始时间（超30分钟自动释放）"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  calculations do
    calculate :full_name, :string, expr(recursive_join(parent(name), name, %{separator: " / ", max_depth: 10}))
    calculate :root_article_id, :uuid, expr(root_ancestor(parent_id))
    calculate :article_url, :string, expr(format("/knowledge/article/{}-{}", id, slugify(name)))
    calculate :body_short, :string, expr(truncate(strip_tags(body), 200))
    calculate :has_write_access, :boolean, expr(check_access(self, current_user, "write"))
    calculate :has_read_access, :boolean, expr(check_access(self, current_user, "read"))
    calculate :is_favorite, :boolean, expr(exists(favorites, user_id == actor.id))
    calculate :version_count, :integer, expr(count(versions, query: [filter: expr(true)]))
    calculate :favorite_count, :integer, expr(count(favorites, query: [filter: expr(true)]))
  end

  relationships do
    belongs_to :parent, UniboExPoc.Knowledge.Article do
      public? true
    end
    has_many :children, UniboExPoc.Knowledge.Article do
      public? true
      source_attribute :parent_id
      destination_attribute :parent_id
    end
    has_many :members, UniboExPoc.Knowledge.ArticleMember do
      public? true
    end
    has_many :versions, UniboExPoc.Knowledge.ArticleVersion do
      public? true
    end
    has_many :favorites, UniboExPoc.Knowledge.Favorite do
      public? true
    end
    many_to_many :tags, UniboExPoc.Knowledge.Tag do
      public? true
      through UniboExPoc.Knowledge.ArticleTagLink
    end
    belongs_to :creator, UniboExPoc.Knowledge.Party do
      public? true
      source_attribute :creator_party_id
    end
    belongs_to :last_writer, UniboExPoc.Knowledge.Party do
      public? true
      source_attribute :last_writer_party_id
    end
    belongs_to :locker, UniboExPoc.Knowledge.Party do
      public? true
      source_attribute :locker_party_id
    end
    belongs_to :last_editor, UniboExPoc.Knowledge.Party do
      public? true
      source_attribute :last_editor_party_id
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
      # relate_actor :create_uid — 无对应关系，跳过
      # relate_actor :write_uid — 无对应关系，跳过
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:name, :body, :sequence, :category, :icon, :cover_image_id, :is_template]
      argument :members, {:array, :map}, default: []
      change manage_relationship(:members, :members, on_lookup: :relate, on_no_match: :create, on_match: :update)
      # skipped: validate policy_check : (incompatible with bulk update atomic path)
      # relate_actor :write_uid — 无对应关系，跳过
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :action_publish do
      description "发布文章（draft → published）"
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
      # skipped: validate policy_check : (incompatible with bulk update atomic path)
      # relate_actor :write_uid — 无对应关系，跳过
      change set_attribute(:state, :published)
      change UniboExPoc.Knowledge.Changes.Article.ActionPublishCall20
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :action_unpublish do
      description "撤销发布（published → draft）"
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
      # skipped: validate policy_check : (incompatible with bulk update atomic path)
      # relate_actor :write_uid — 无对应关系，跳过
      change set_attribute(:state, :draft)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :action_archive do
      description "归档文章（published → archived），递归归档所有后代"
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
      # skipped: validate policy_check : (incompatible with bulk update atomic path)
      # relate_actor :write_uid — 无对应关系，跳过
      change set_attribute(:state, :archived)
      change UniboExPoc.Knowledge.Changes.Article.ActionArchiveCall17
      change UniboExPoc.Knowledge.Changes.Article.ActionArchiveCall20
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :action_restore_state do
      description "从归档恢复（archived → draft）"
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
      # skipped: validate policy_check : (incompatible with bulk update atomic path)
      # relate_actor :write_uid — 无对应关系，跳过
      change set_attribute(:state, :draft)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :action_trash do
      description "移入回收站（软删除），递归处理后代"
      accept []
      # skipped: validate policy_check : (incompatible with bulk update atomic path)
      # skipped: validate policy_check : (incompatible with bulk update atomic path)
      # skipped: validate compare :active (incompatible with bulk update atomic path)
      # relate_actor :write_uid — 无对应关系，跳过
      change set_attribute(:active, false)
      change UniboExPoc.Knowledge.Changes.Article.ComputeTrashedDate
      change UniboExPoc.Knowledge.Changes.Article.ActionTrashCall18
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :action_restore_trash do
      description "从回收站恢复"
      accept []
      # skipped: validate policy_check : (incompatible with bulk update atomic path)
      # skipped: validate policy_check : (incompatible with bulk update atomic path)
      # skipped: validate compare :active (incompatible with bulk update atomic path)
      # relate_actor :write_uid — 无对应关系，跳过
      change set_attribute(:active, true)
      change UniboExPoc.Knowledge.Changes.Article.ActionRestoreTrashCall19
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :action_lock do
      description "抢锁开始编辑"
      accept []
      # skipped: validate policy_check : (incompatible with bulk update atomic path)
      # relate_actor :write_uid — 无对应关系，跳过
      change set_attribute(:is_locked, true)
      # relate_actor :locked_by — 无对应关系，跳过
      change UniboExPoc.Knowledge.Changes.Article.ComputeLockedAt
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :action_unlock do
      description "释放锁（保存版本快照后解锁）"
      accept []
      # skipped: validate policy_check : (incompatible with bulk update atomic path)
      # relate_actor :write_uid — 无对应关系，跳过
      change set_attribute(:is_locked, false)
      change UniboExPoc.Knowledge.Changes.Article.ActionUnlockCall20
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :action_move do
      description "移动文章到新父级，检查循环引用"
      argument :new_parent_id, :uuid
      # skipped: validate policy_check : (incompatible with bulk update atomic path)
      # skipped: validate compare :parent_id (incompatible with bulk update atomic path)
      # relate_actor :write_uid — 无对应关系，跳过
      change UniboExPoc.Knowledge.Changes.Article.ActionMoveCall16
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    create :action_copy do
      description "深拷贝文章（递归复制子文章+member权限，不复制版本历史）"
      argument :source_article_id, :uuid, allow_nil?: false
      argument :members, {:array, :map}, default: []
      change manage_relationship(:members, :members, type: :create)
      validate present(:name)
      # relate_actor :create_uid — 无对应关系，跳过
      # relate_actor :write_uid — 无对应关系，跳过
      change UniboExPoc.Knowledge.Changes.Article.ActionCopyCall21
      change set_attribute(:id, expr(id))
    end
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
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
