defmodule UniboV4.Documents.FolderWorkflowRuleLink do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Documents,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "文件夹-工作流规则桥接占位实体"
  end

  postgres do
    table "documents_folder_workflow_rule_links"
    repo UniboV4.Repo
  end

  graphql do
    type :documents_folder_workflow_rule_link

    queries do
      get :get_documents_folder_workflow_rule_link, :read
      list :list_documents_folder_workflow_rule_links, :read
    end

  end

  attributes do
    uuid_primary_key :id
  end

  relationships do
    belongs_to :folder, UniboV4.Documents.Folder do
      public? true
      allow_nil? false
    end
    belongs_to :workflow_rule, UniboV4.Documents.WorkflowRule do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read, :update]
  end

end
