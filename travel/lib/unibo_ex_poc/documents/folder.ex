# Workflow: folder_management_flow — 文件夹创建、更新与删除维护流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
#   destroy --> [*]
# ```
defmodule UniboExPoc.Documents.Folder do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Documents,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource],
    authorizers: [Ash.Policy.Authorizer]

  resource do
    description "文件夹/工作区，作为文档的容器兼配置单元（type=folder 的 Document 扩展字段）"
  end

  postgres do
    table "documents_folders"
    repo UniboExPoc.Repo
  end

  graphql do
    type :documents_folder

    queries do
      get :get_documents_folder, :read
      list :list_documents_folders, :read
    end

    mutations do
      create :create_documents_folder, :create
      update :update_documents_folder, :update
      destroy :delete_documents_folder, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :user_specific, :boolean do
      default false
      public? true
      description "是否按用户隔离文档可见性"
    end
    attribute :sequence, :integer do
      public? true
      description "排序序号"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    has_many :children, UniboExPoc.Documents.Document do
      public? true
    end
    belongs_to :parent_folder, UniboExPoc.Documents.Document do
      public? true
    end
    many_to_many :actions, UniboExPoc.Documents.WorkflowRule do
      public? true
      through UniboExPoc.Documents.FolderWorkflowRuleLink
    end
    has_many :facets, UniboExPoc.Documents.Facet do
      public? true
    end
    many_to_many :read_groups, UniboExPoc.Documents.Group do
      public? true
      through UniboExPoc.Documents.FolderReadGroupLink
    end
    many_to_many :write_groups, UniboExPoc.Documents.Group do
      public? true
      through UniboExPoc.Documents.FolderWriteGroupLink
    end
    belongs_to :company, UniboExPoc.Documents.Party do
      public? true
      source_attribute :company_party_id
    end
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:parent_folder_id, :user_specific, :sequence]
      argument :company_id, :uuid
      # validation: custom_check
      # validation: custom_check
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:parent_folder_id, :user_specific, :sequence]
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
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
    archive_related [:children, :facets]
  end

  policies do
    policy action_type(:read) do
      authorize_if expr(actor.role == :admin or expr(fragment("? && ?", actor.groups, read_groups)))
    end
    policy action_type(:update) do
      authorize_if expr(actor.role == :admin or expr(fragment("? && ?", actor.groups, write_groups)))
    end
  end

end
