# Workflow: tag_management — 标签维护流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> destroy
#   update --> update
#   update --> destroy
#   destroy --> [*]
# ```
defmodule UniboExPoc.Knowledge.Tag do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Knowledge,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "文章标签，与 Article 多对多关联"
  end

  postgres do
    table "knowledge_tags"
    repo UniboExPoc.Repo
  end

  graphql do
    type :knowledge_tag

    queries do
      get :get_knowledge_tag, :read
      list :list_knowledge_tags, :read
    end

    mutations do
      create :create_knowledge_tag, :create
      update :update_knowledge_tag, :update
      destroy :delete_knowledge_tag, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
      description "标签名称（唯一）"
    end
    attribute :color, :integer do
      public? true
      description "标签颜色索引"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    many_to_many :articles, UniboExPoc.Knowledge.Article do
      public? true
      through UniboExPoc.Knowledge.ArticleTagLink
    end
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:name, :color]
      validate present(:name)
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:name, :color]
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  identities do
    identity :unique_tag_name, [:name]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
  end

end
