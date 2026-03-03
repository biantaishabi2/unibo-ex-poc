# Workflow: favorite_management — 收藏管理流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> reorder
#   create --> destroy
#   reorder --> reorder
#   reorder --> destroy
#   destroy --> [*]
# ```
defmodule UniboV4.Knowledge.Favorite do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Knowledge,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "knowledge_favorites"
    repo UniboV4.Repo
  end

  graphql do
    type :knowledge_favorite

    mutations do
      create :create_knowledge_favorite, :create
      update :reorder_knowledge_favorite, :reorder
      destroy :delete_knowledge_favorite, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :sequence, :integer do
      allow_nil? false
      default 0
      public? true
    end
    create_timestamp :inserted_at
  end

  relationships do
    belongs_to :article, UniboV4.Knowledge.Article do
      public? true
      allow_nil? false
    end
    belongs_to :user, UniboV4.Knowledge.User do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:destroy, :read]
    create :create do
      primary? true
      accept [:sequence]
      argument :article_id, :uuid, allow_nil?: false
      change manage_relationship(:article_id, :article, type: :append, on_lookup: :relate)
      argument :user_id, :uuid, allow_nil?: false
      change manage_relationship(:user_id, :user, type: :append, on_lookup: :relate)
      validate present(:article_id)
      validate present(:user_id)
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
    end
    update :reorder do
      primary? true
      accept [:sequence]
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
    identity :unique_user_article, [:article_id, :user_id]
  end

end
