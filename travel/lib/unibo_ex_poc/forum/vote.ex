# Workflow: vote_lifecycle — 投票生命周期
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   update --> update
# ```
defmodule UniboExPoc.Forum.Vote do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Forum,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource],
    notifiers: [UniboExPoc.Forum.Vote.Notifier]

  resource do
    description "帖子投票记录，驱动 Karma 生成与回退"
  end

  postgres do
    table "forum_votes"
    repo UniboExPoc.Repo
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
    belongs_to :post, UniboExPoc.Forum.Post do
      public? true
      allow_nil? false
    end
    belongs_to :user, UniboExPoc.Forum.Party do
      public? true
      allow_nil? false
      source_attribute :user_party_id
    end
    belongs_to :forum, UniboExPoc.Forum.Forum do
      public? true
    end
    belongs_to :recipient, UniboExPoc.Forum.Party do
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
      validate present(:)
      # message: "Karma 不足，无法点赞"
      validate present(:)
      # message: "Karma 不足，无法点踩"
      change relate_actor(:user)
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
      description "更改投票（含切换和取消逻辑）"
      primary? true
      accept [:vote]
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
    identity :unique_user_post_vote, [:user_id, :post_id]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
