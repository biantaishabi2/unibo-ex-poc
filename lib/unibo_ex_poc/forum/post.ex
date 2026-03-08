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
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Forum,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource],
    authorizers: [Ash.Policy.Authorizer],
    notifiers: [UniboV4.Forum.Post.Notifier]

  resource do
    description "帖子实体，通过 parent_id 区分问题（null）与回答（非null）"
  end

  postgres do
    table "forum_posts"
    repo UniboV4.Repo
  end

  graphql do
    type :forum_post

    queries do
      get :get_forum_post, :read
      list :list_forum_posts, :read
    end

    mutations do
      create :create_forum_post, :create
      update :update_forum_post, :update
      update :close_forum_post, :close
      update :reopen_forum_post, :reopen
      update :flag_forum_post, :flag
      update :mark_offensive_forum_post, :mark_offensive
      update :validate_forum_post, :validate
      update :accept_answer_forum_post, :accept_answer
      update :unaccept_answer_forum_post, :unaccept_answer
      update :toggle_favourite_forum_post, :toggle_favourite
      destroy :delete_forum_post, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
      description "帖子标题（仅问题级别需要）"
    end
    attribute :content, :string do
      allow_nil? false
      public? true
      description "帖子内容（经 sanitize 处理）"
    end
    attribute :post_type, :atom do
      constraints one_of: [:question, :link, :discussion]
      public? true
      description "帖子类型"
    end
    attribute :state, :atom do
      constraints one_of: [:active, :pending, :close, :offensive, :flagged]
      default :active
      public? true
      description "帖子状态"
    end
    attribute :is_correct, :boolean do
      default false
      public? true
      description "是否为采纳的最佳答案"
    end
    attribute :views, :integer do
      default 0
      public? true
      description "浏览数"
    end
    attribute :last_activity_date, :utc_datetime do
      public? true
      description "最后活跃时间，默认为创建时间"
    end
    attribute :close_date, :utc_datetime do
      public? true
      description "关闭时间"
    end
    attribute :close_reason_id, :uuid do
      public? true
      description "关闭原因"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  calculations do
    calculate :plain_content, :string, expr(truncate(html2plaintext(content), 500))
    calculate :website_url, :string, expr(format("/forum/{}/{}", forum.slug, slug))
    calculate :vote_count, :integer, expr(sum(votes, field: :vote, query: [filter: expr(true)]))
    calculate :user_vote, :integer, expr(coalesce(0))
    calculate :favourite_count, :integer, expr(count(favourites, query: [filter: expr(true)]))
    calculate :user_favourite, :boolean, expr(contains(favourites, current_user))
    calculate :child_count, :integer, expr(count(children, query: [filter: expr(true)]))
    calculate :has_validated_answer, :boolean, expr(exists())
    calculate :uid_has_answered, :boolean, expr(exists())
    calculate :self_reply, :boolean, expr(create_uid == parent(create_uid))
    calculate :relevancy, :decimal, expr(((sign(vote_count) * pow(abs((vote_count - 1)), forum.relevancy_post_vote)) / pow((days_since(inserted_at) + 2), forum.relevancy_time_decay)))
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
      source_attribute :parent_id
      destination_attribute :parent_id
    end
    belongs_to :create_uid, UniboV4.Forum.Party do
      public? true
      source_attribute :create_uid_party_id
    end
    belongs_to :moderator, UniboV4.Forum.Party do
      public? true
      source_attribute :moderator_party_id
    end
    belongs_to :closed_uid, UniboV4.Forum.Party do
      public? true
      source_attribute :closed_uid_party_id
    end
    has_many :votes, UniboV4.Forum.Vote do
      public? true
    end
    many_to_many :tags, UniboV4.Forum.Tag do
      public? true
      through UniboV4.Forum.PostTagLink
    end
    many_to_many :favourites, UniboV4.Forum.Party do
      public? true
      through UniboV4.Forum.PostFavoriteLink
      destination_attribute_on_join_resource :user_party_id
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
      # validation: karma_check_ask — Karma 不足，无法提问
      change relate_actor(:create_uid)
      change UniboV4.Forum.Changes.Post.ComputeLastActivityDate
      change set_attribute(:state, expr(if(actor.karma >= forum.karma_moderate, :active, :pending)))
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:name, :content]
      argument :tag_ids, :string
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :close do
      description "关闭帖子"
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
      change UniboV4.Forum.Changes.Post.ComputeCloseDate
      change relate_actor(:closed_uid)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :reopen do
      description "重新打开帖子"
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
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :flag do
      description "标记帖子"
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
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :mark_offensive do
      description "确认帖子冒犯并施加 Karma 惩罚"
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
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :validate do
      description "版主审核通过待审核帖子"
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
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :accept_answer do
      description "采纳为最佳答案"
      accept []
      # skipped: validate present :parent_id (incompatible with bulk update atomic path)
      change set_attribute(:is_correct, true)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :unaccept_answer do
      description "取消采纳"
      accept []
      # skipped: validate present :parent_id (incompatible with bulk update atomic path)
      change set_attribute(:is_correct, false)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :toggle_favourite do
      description "切换收藏状态"
      accept []
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
    archive_related [:children, :votes]
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
