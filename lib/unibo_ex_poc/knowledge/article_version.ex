# Workflow: article_version_creation — 文章版本创建流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
# ```
defmodule UniboExPoc.Knowledge.ArticleVersion do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Knowledge,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "文章版本历史，只读归档，支持从任意版本恢复"
  end

  postgres do
    table "knowledge_article_versions"
    repo UniboExPoc.Repo
  end

  graphql do
    type :knowledge_article_version

    queries do
      get :get_knowledge_article_version, :read
      list :list_knowledge_article_versions, :read
    end

    mutations do
      create :create_knowledge_article_version, :create
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :body, :string do
      allow_nil? false
      public? true
      description "版本快照内容"
    end
    attribute :name, :string do
      allow_nil? false
      public? true
      description "自动编号 v1, v2, v3..."
    end
    attribute :type, :atom do
      allow_nil? false
      constraints one_of: [:version, :draft, :autosave]
      public? true
      description "版本类型：version（正式保存）、draft（草稿）、autosave（自动保存）"
    end
    create_timestamp :inserted_at
  end

  calculations do
    calculate :diff_summary, :string, expr(version_diff(article_id, name))
  end

  relationships do
    belongs_to :article, UniboExPoc.Knowledge.Article do
      public? true
      allow_nil? false
    end
    belongs_to :creator, UniboExPoc.Knowledge.Party do
      public? true
      source_attribute :creator_party_id
    end
  end

  actions do
    defaults [:read, :update]
    create :create do
      primary? true
      accept [:article_id, :body, :type]
      argument :article_id, :uuid, allow_nil?: false
      change manage_relationship(:article_id, :article, type: :append, on_lookup: :relate)
      validate present(:article_id)
      validate present(:body)
      change UniboExPoc.Knowledge.Changes.ArticleVersion.CreateCall1
      change set_attribute(:id, expr(id))
    end
  end

end
