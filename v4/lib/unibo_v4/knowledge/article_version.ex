# Workflow: article_version_creation — 文章版本创建流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
# ```
defmodule UniboV4.Knowledge.ArticleVersion do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Knowledge,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "knowledge_article_versions"
    repo UniboV4.Repo
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
    end
    attribute :name, :string do
      allow_nil? false
      public? true
    end
    attribute :type, :atom do
      allow_nil? false
      constraints one_of: [:version, :draft, :autosave]
      public? true
    end
    create_timestamp :inserted_at
  end

  calculations do
    # TODO: 不支持的 calculation 表达式 :diff_summary
  end

  relationships do
    belongs_to :article, UniboV4.Knowledge.Article do
      public? true
      allow_nil? false
    end
    belongs_to :creator, UniboV4.Knowledge.User do
      public? true
      source_attribute :version_uid
    end
  end

  actions do
    defaults [:read, :update]
    create :create do
      primary? true
      accept [:body, :type]
      argument :article_id, :uuid, allow_nil?: false
      change manage_relationship(:article_id, :article, type: :append, on_lookup: :relate)
      validate present(:article_id)
      validate present(:body)
      validate present(:version_uid)
      # TODO: 不支持的 change effect custom
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
    end
  end

end
