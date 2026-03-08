defmodule UniboExPoc.Documents.FolderWorkflowRuleLink do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Documents,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "文件夹-工作流规则桥接占位实体"
  end

  postgres do
    table "documents_folder_workflow_rule_links"
    repo UniboExPoc.Repo
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
    belongs_to :folder, UniboExPoc.Documents.Folder do
      public? true
      allow_nil? false
    end
    belongs_to :workflow_rule, UniboExPoc.Documents.WorkflowRule do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read, :update]
  end

end
