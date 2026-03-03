# Workflow: folder_management_flow — 文件夹创建、更新与删除维护流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
#   destroy --> [*]
# ```
defmodule UniboV4.Documents.Folder do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Documents,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource],
    authorizers: [Ash.Policy.Authorizer]

  postgres do
    table "documents_folders"
    repo UniboV4.Repo
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
    attribute :parent_folder_id, :uuid, public?: true
    attribute :user_specific, :boolean do
      default false
      public? true
    end
    attribute :sequence, :integer, public?: true
    attribute :company_id, :uuid, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :children, UniboV4.Documents.Document do
      public? true
    end
    belongs_to :parent_folder, UniboV4.Documents.Document do
      public? true
    end
    many_to_many :actions, UniboV4.Documents.WorkflowRule do
      public? true
      through UniboV4.Documents.FolderWorkflowRuleLink
    end
    has_many :facets, UniboV4.Documents.Facet do
      public? true
    end
    many_to_many :read_groups, UniboV4.Documents.Group do
      public? true
      through UniboV4.Documents.FolderReadGroupLink
    end
    many_to_many :write_groups, UniboV4.Documents.Group do
      public? true
      through UniboV4.Documents.FolderWriteGroupLink
    end
    belongs_to :company, UniboV4.Documents.Company do
      public? true
    end
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:parent_folder_id, :user_specific, :sequence, :company_id]
      # TODO: 不支持的 action 内校验规则 custom
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
      accept [:parent_folder_id, :user_specific, :sequence]
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
  end

  policies do
    policy action_type(:read) do
      authorize_if expr(role == :admin or expr(fragment("? && ?", groups, read_groups)))
    end
    policy action_type(:update) do
      authorize_if expr(role == :admin or expr(fragment("? && ?", groups, write_groups)))
    end
  end

end
