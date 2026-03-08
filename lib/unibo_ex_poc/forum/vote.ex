# Workflow: vote_lifecycle — 投票生命周期
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   update --> update
# ```
defmodule UniboV4.Forum.Vote do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Forum,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource],
    notifiers: [UniboV4.Forum.Vote.Notifier]

  resource do
    description "帖子投票记录，驱动 Karma 生成与回退"
  end

  postgres do
    table "forum_votes"
    repo UniboV4.Repo
  end

  graphql do
    type :forum_vote

    mutations do
      create :create_forum_vote, :create
      update :update_forum_vote, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :vote, :atom do
      allow_nil? false
      constraints one_of: [:"1", :"-1", :"0"]
      public? true
      description "投票值（1=赞，-1=踩，0=取消）"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :post, UniboV4.Forum.Post do
      public? true
      allow_nil? false
    end
    belongs_to :user, UniboV4.Forum.Party do
      public? true
      allow_nil? false
      source_attribute :user_party_id
    end
    belongs_to :forum, UniboV4.Forum.Forum do
      public? true
    end
    belongs_to :recipient, UniboV4.Forum.Party do
      public? true
      source_attribute :recipient_party_id
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:vote]
      argument :post_id, :uuid, allow_nil?: false
      change manage_relationship(:post_id, :post, type: :append, on_lookup: :relate)
      argument :user_id, :uuid, allow_nil?: false
      change manage_relationship(:user_id, :user, type: :append, on_lookup: :relate)
      validate present(:vote)
      # validation: karma_check_upvote — Karma 不足，无法点赞
      # validation: karma_check_downvote — Karma 不足，无法点踩
      change relate_actor(:user)
      change set_attribute(:id, expr(id))
    end
    update :update do
      description "更改投票（含切换和取消逻辑）"
      primary? true
      accept [:vote]
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  identities do
    identity :unique_user_post_vote, [:user_id, :post_id]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
