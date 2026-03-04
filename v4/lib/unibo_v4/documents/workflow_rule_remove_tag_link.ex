defmodule UniboV4.Documents.WorkflowRuleRemoveTagLink do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Documents,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "documents_workflow_rule_remove_tag_links"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
  end

  relationships do
    belongs_to :workflow_rule, UniboV4.Documents.WorkflowRule do
      public? true
      allow_nil? false
    end
    belongs_to :tag, UniboV4.Documents.Tag do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read]
  end

end
