# Workflow: spreadsheet_document_lifecycle_flow — 电子表格文档创建、更新、模板派生与删除流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
#   create_from_template --> [*]
#   destroy --> [*]
# ```
defmodule UniboExPoc.Spreadsheet.SpreadsheetDocument do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Spreadsheet,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "电子表格文档，承载完整的工作表状态（sheets/styles/formats/pivots/settings）"
  end

  postgres do
    table "spreadsheet_documents"
    repo UniboExPoc.Repo
  end

  graphql do
    type :spreadsheet_spreadsheet_document

    queries do
      get :get_spreadsheet_spreadsheet_document, :read
      list :list_spreadsheet_spreadsheet_documents, :read
    end

    mutations do
      create :create_create_spreadsheet_spreadsheet_document, :create
      create :create_create_from_template_spreadsheet_spreadsheet_document, :create_from_template
      update :update_spreadsheet_spreadsheet_document, :update
      destroy :delete_spreadsheet_spreadsheet_document, :destroy
    end

  end

  attributes do
    attribute :id, :integer do
      primary_key? true
      allow_nil? false
      generated? true
      public? true
      description "文档 ID"
    end
    attribute :name, :string do
      allow_nil? false
      public? true
      description "文档名称"
    end
    attribute :is_template, :boolean do
      default false
      public? true
      description "是否为模板"
    end
    attribute :thumbnail, :string do
      public? true
      description "缩略图"
    end
    attribute :data, :string do
      allow_nil? false
      default "{}"
      public? true
      description "完整电子表格状态（sheets/styles/formats/borders/pivots/settings）"
    end
    attribute :version, :string do
      allow_nil? false
      public? true
      description "数据模型版本号，用于兼容性检查和升级迁移"
    end
    attribute :current_revision_id, :string do
      default "START_REVISION"
      public? true
      description "当前修订版本 ID，协作同步锚点"
    end
    attribute :mode, :atom do
      allow_nil? false
      constraints one_of: [:normal, :readonly, :dashboard]
      default :normal
      public? true
      description "运行模式（非流转状态机，可任意切换）"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  calculations do
    calculate :sheet_count, :integer, expr(length(sheets))
    calculate :collaborator_count, :integer, {UniboExPoc.Spreadsheet.Calculations.SpreadsheetDocument.CollaboratorCount, []}
  end

  relationships do
    belongs_to :owner, UniboExPoc.Spreadsheet.Party do
      public? true
      allow_nil? false
      source_attribute :owner_party_id
    end
    has_many :data_sources, UniboExPoc.Spreadsheet.DataSource do
      public? true
      source_attribute :owner_party_id
      destination_attribute :document_id
    end
    has_many :global_filters, UniboExPoc.Spreadsheet.GlobalFilter do
      public? true
      source_attribute :owner_party_id
      destination_attribute :document_id
    end
    has_many :revisions, UniboExPoc.Spreadsheet.Revision do
      public? true
      source_attribute :owner_party_id
      destination_attribute :document_id
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:name, :data, :version, :mode, :is_template]
      argument :owner_id, :uuid, allow_nil?: false
      change manage_relationship(:owner_id, :owner, type: :append, on_lookup: :relate)
      # validation: figure_id_global_unique — 图表 ID 必须跨工作表全局唯一
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:name, :data, :mode, :thumbnail]
      # skipped: validate compare :is_template (incompatible with bulk update atomic path)
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    create :create_from_template do
      description "从模板创建新文档"
      argument :template_id, :integer, allow_nil?: false
      argument :owner_id, :uuid, allow_nil?: false
      change manage_relationship(:owner_id, :owner, type: :append, on_lookup: :relate)
      # validation: figure_id_global_unique — 图表 ID 必须跨工作表全局唯一
      change set_attribute(:id, expr(id))
    end
    destroy :destroy do
      description "删除文档（级联删除关联的 DataSource、GlobalFilter、Revision）"
      primary? true
      # validation: cascade_delete
      change set_attribute(:id, expr(id))
    end
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
    archive_related [:data_sources, :global_filters, :revisions]
  end

end
