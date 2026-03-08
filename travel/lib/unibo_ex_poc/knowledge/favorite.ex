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
defmodule UniboExPoc.Knowledge.Favorite do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Knowledge,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "用户文章收藏，支持拖拽排序"
  end

  postgres do
    table "knowledge_favorites"
    repo UniboExPoc.Repo
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
      description "用户自定义排序（拖拽调整）"
    end
    create_timestamp :inserted_at
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :article, UniboExPoc.Knowledge.Article do
      public? true
      allow_nil? false
    end
    belongs_to :user, UniboExPoc.Knowledge.Party do
      public? true
      allow_nil? false
      source_attribute :user_party_id
    end
  end

  actions do
    defaults [:destroy, :read]
    create :create do
      primary? true
      accept [:article_id, :sequence]
      argument :user_id, :uuid
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
      description "拖拽调整排序，批量更新 sequence"
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

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
  end

end
