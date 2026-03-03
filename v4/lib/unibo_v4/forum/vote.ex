# Workflow: vote_lifecycle — 投票生命周期
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   update --> update
# ```
defmodule UniboV4.Forum.Vote do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Forum,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource],
    notifiers: [UniboV4.Forum.Vote.Notifier]

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
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :post, UniboV4.Forum.Post do
      public? true
      allow_nil? false
    end
    belongs_to :user, UniboV4.Forum.User do
      public? true
      allow_nil? false
    end
    belongs_to :forum, UniboV4.Forum.Forum do
      public? true
    end
    belongs_to :recipient, UniboV4.Forum.User do
      public? true
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
      # TODO: 不支持的 action 内校验规则 custom
      # TODO: 不支持的 action 内校验规则 custom
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

end
