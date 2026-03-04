# Workflow: post_lifecycle — 帖子生命周期（创建→审核→活跃→关闭/冒犯）
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> validate
#   create --> update
#   create --> close
#   create --> flag
#   create --> accept_answer
#   create --> toggle_favourite
#   create --> destroy
#   validate --> update
#   validate --> close
#   validate --> flag
#   validate --> accept_answer
#   validate --> toggle_favourite
#   update --> update
#   update --> close
#   update --> flag
#   update --> accept_answer
#   update --> toggle_favourite
#   update --> destroy
#   close --> reopen
#   reopen --> update
#   reopen --> close
#   reopen --> flag
#   flag --> mark_offensive
#   mark_offensive --> [*] : marked_offensive
#   accept_answer --> unaccept_answer
#   unaccept_answer --> accept_answer
#   toggle_favourite --> toggle_favourite
#   toggle_favourite --> update
#   toggle_favourite --> close
#   destroy --> [*]
# ```
defmodule UniboV4.Forum.Post do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Forum,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer],
    notifiers: [UniboV4.Forum.Post.Notifier]

  postgres do
    table "forum_posts"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
    end
    attribute :content, :string do
      allow_nil? false
      public? true
    end
    attribute :post_type, :atom do
      constraints one_of: [:question, :link, :discussion]
      public? true
    end
    attribute :state, :atom do
      constraints one_of: [:active, :pending, :close, :offensive, :flagged]
      default :active
      public? true
    end
    attribute :is_correct, :boolean do
      default false
      public? true
    end
    attribute :views, :integer do
      default 0
      public? true
    end
    attribute :last_activity_date, :utc_datetime, public?: true
    attribute :close_date, :utc_datetime, public?: true
    attribute :close_reason_id, :uuid, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  calculations do
    # TODO: 不支持的 calculation 表达式 :plain_content
    # TODO: 不支持的 calculation 表达式 :website_url
    calculate :vote_count, :integer, expr(sum(votes, field: :vote, query: [filter: expr(true)]))
    # TODO: 不支持的 calculation 表达式 :user_vote
    calculate :favourite_count, :integer, expr(count(favourites, query: [filter: expr(true)]))
    # TODO: 不支持的 calculation 表达式 :user_favourite
    calculate :child_count, :integer, expr(count(children, query: [filter: expr(true)]))
    # TODO: 不支持的 calculation 表达式 :has_validated_answer
    # TODO: 不支持的 calculation 表达式 :uid_has_answered
    # TODO: 不支持的 calculation 表达式 :self_reply
    # TODO: 不支持的 calculation 表达式 :relevancy
  end

  relationships do
    belongs_to :forum, UniboV4.Forum.Forum do
      public? true
      allow_nil? false
    end
    belongs_to :parent, UniboV4.Forum.Post do
      public? true
    end
    has_many :children, UniboV4.Forum.Post do
      public? true
      destination_attribute :parent_id
    end
    belongs_to :create_uid, UniboV4.Forum.User do
      public? true
    end
    belongs_to :moderator, UniboV4.Forum.User do
      public? true
    end
    belongs_to :closed_uid, UniboV4.Forum.User do
      public? true
    end
    has_many :votes, UniboV4.Forum.Vote do
      public? true
    end
    many_to_many :tags, UniboV4.Forum.Tag do
      public? true
      through UniboV4.Forum.PostTagLink
    end
    many_to_many :favourites, UniboV4.Forum.User do
      public? true
      through UniboV4.Forum.PostFavoriteLink
    end
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:name, :content, :post_type]
      argument :forum_id, :uuid, allow_nil?: false
      argument :parent_id, :uuid
      argument :tag_ids, {:array, :string}
      change manage_relationship(:forum_id, :forum, type: :append, on_lookup: :relate)
      validate present(:name)
      validate present(:content)
      # TODO: 不支持的 action 内校验规则 custom
      change relate_actor(:create_uid)
      # TODO: 跨实体聚合表达式暂不支持
      # TODO: 不支持的表达式类型
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
      accept [:name, :content]
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
    update :close do
      argument :close_reason_id, :uuid, allow_nil?: false
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :state)
        if current == :active do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :state, message: "must equal %{value}", vars: %{value: :active}))
        end
      end
      # message: "只有活跃状态的帖子可以关闭"
      change set_attribute(:state, :close)
      # TODO: 跨实体聚合表达式暂不支持
      change relate_actor(:closed_uid)
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
    update :reopen do
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :state)
        if current == :close do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :state, message: "must equal %{value}", vars: %{value: :close}))
        end
      end
      # message: "只有已关闭的帖子可以重新打开"
      change set_attribute(:state, :active)
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
    update :flag do
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :state)
        if current == :active do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :state, message: "must equal %{value}", vars: %{value: :active}))
        end
      end
      # message: "只有活跃状态的帖子可以标记"
      # skipped: validate custom : (incompatible with bulk update atomic path)
      change set_attribute(:state, :flagged)
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
    update :mark_offensive do
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :state)
        if current == :flagged do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :state, message: "must equal %{value}", vars: %{value: :flagged}))
        end
      end
      # message: "只有已标记的帖子可以确认冒犯"
      change set_attribute(:state, :offensive)
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
    update :validate do
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :state)
        if current == :pending do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :state, message: "must equal %{value}", vars: %{value: :pending}))
        end
      end
      # message: "只有待审核的帖子可以通过审核"
      change set_attribute(:state, :active)
      change relate_actor(:moderator)
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
    update :accept_answer do
      accept []
      # skipped: validate present(:parent_id) — field not found
      change set_attribute(:is_correct, true)
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
    update :unaccept_answer do
      accept []
      # skipped: validate present(:parent_id) — field not found
      change set_attribute(:is_correct, false)
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
    update :toggle_favourite do
      accept []
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
    policy always() do
      authorize_if expr(actor.is_admin)
    end
    policy action_type(:read) do
      authorize_if always()
    end
    policy action_type(:create) do
      authorize_if expr(actor.karma >= forum.karma_ask or actor.karma >= forum.karma_answer)
    end
    policy action_type(:update) do
      authorize_if expr(actor.id == create_uid_id and actor.karma >= forum.karma_edit_own)
    end
    policy action_type(:update) do
      authorize_if expr(actor.karma >= forum.karma_edit_all)
    end
    policy action_type(:destroy) do
      authorize_if expr(actor.id == create_uid_id and actor.karma >= forum.karma_unlink_own)
    end
    policy action_type(:destroy) do
      authorize_if expr(actor.karma >= forum.karma_unlink_all)
    end
  end

end
