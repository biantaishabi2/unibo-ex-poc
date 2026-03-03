# Workflow: spreadsheet_document_lifecycle_flow — 电子表格文档创建、更新、模板派生与删除流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
#   create_from_template --> [*]
#   destroy --> [*]
# ```
defmodule UniboV4.Spreadsheet.SpreadsheetDocument do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Spreadsheet,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "spreadsheet_documents"
    repo UniboV4.Repo
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
      public? true
    end
    attribute :name, :string do
      allow_nil? false
      public? true
    end
    attribute :is_template, :boolean do
      default false
      public? true
    end
    attribute :thumbnail, :string, public?: true
    attribute :data, :string do
      allow_nil? false
      default "{}"
      public? true
    end
    attribute :version, :string do
      allow_nil? false
      public? true
    end
    attribute :current_revision_id, :string do
      default "START_REVISION"
      public? true
    end
    attribute :mode, :atom do
      allow_nil? false
      constraints one_of: [:normal, :readonly, :dashboard]
      default :normal
      public? true
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  calculations do
    # TODO: 不支持的 calculation 表达式 :sheet_count
    # TODO: 不支持的 calculation 表达式 :collaborator_count
  end

  relationships do
    belongs_to :owner, UniboV4.Spreadsheet.User do
      public? true
      allow_nil? false
    end
    has_many :data_sources, UniboV4.Spreadsheet.DataSource do
      public? true
      destination_attribute :document_id
    end
    has_many :global_filters, UniboV4.Spreadsheet.GlobalFilter do
      public? true
      destination_attribute :document_id
    end
    has_many :revisions, UniboV4.Spreadsheet.Revision do
      public? true
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
      # TODO: 不支持的 action 内校验规则 custom
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
      accept [:name, :data, :mode, :thumbnail]
      # skipped: validate custom : (incompatible with bulk update atomic path)
      # skipped: validate custom : (incompatible with bulk update atomic path)
      # skipped: validate custom : (incompatible with bulk update atomic path)
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
    create :create_from_template do
      argument :template_id, :integer, allow_nil?: false
      argument :owner_id, :uuid, allow_nil?: false
      change manage_relationship(:owner_id, :owner, type: :append, on_lookup: :relate)
      # TODO: 不支持的 action 内校验规则 custom
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
    end
    destroy :destroy do
      primary? true
      # TODO: 不支持的 action 内校验规则 custom
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
