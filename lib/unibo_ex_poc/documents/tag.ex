# Workflow: tag_lifecycle_flow — 标签创建、编辑与删除流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
#   destroy --> [*]
# ```
defmodule UniboV4.Documents.Tag do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Documents,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "文档标签，归属于 Facet 分类"
  end

  postgres do
    table "documents_tags"
    repo UniboV4.Repo
  end

  graphql do
    type :documents_tag

    queries do
      get :get_documents_tag, :read
      list :list_documents_tags, :read
    end

    mutations do
      create :create_documents_tag, :create
      update :update_documents_tag, :update
      destroy :delete_documents_tag, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
      description "标签名称（如\"已审核\"、\"待处理\"）"
    end
    attribute :sequence, :integer do
      public? true
      description "显示排序"
    end
    attribute :color, :integer do
      public? true
      description "标签颜色索引（0-11）"
    end
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :facet, UniboV4.Documents.Facet do
      public? true
      allow_nil? false
    end
    many_to_many :documents, UniboV4.Documents.Document do
      public? true
      through UniboV4.Documents.DocumentTagLink
    end
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:name, :facet_id, :sequence, :color]
      argument :facet_id, :uuid, allow_nil?: false
      change manage_relationship(:facet_id, :facet, type: :append, on_lookup: :relate)
      validate present(:name)
      validate present(:facet_id)
      # message: "每个 Tag 必须属于一个 Facet"
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:name, :sequence, :color]
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  identities do
    identity :unique_tag_name_per_facet, [:facet_id, :name]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
  end

end
