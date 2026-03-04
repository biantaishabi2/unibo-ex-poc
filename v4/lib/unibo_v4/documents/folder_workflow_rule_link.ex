defmodule UniboV4.Documents.FolderWorkflowRuleLink do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Documents,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "documents_folder_workflow_rule_links"
    repo UniboV4.Repo
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
    defaults [:read]
  end

end
