defmodule UniboExPoc.Documents.WorkflowRuleRemoveTagLink do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Documents,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "工作流规则-移除标签桥接占位实体"
  end

  postgres do
    table "documents_workflow_rule_remove_tag_links"
    repo UniboExPoc.Repo
  end

  graphql do
    type :documents_workflow_rule_remove_tag_link

    queries do
      get :get_documents_workflow_rule_remove_tag_link, :read
      list :list_documents_workflow_rule_remove_tag_links, :read
    end

  end

  attributes do
    uuid_primary_key :id
  end

  relationships do
    belongs_to :workflow_rule, UniboExPoc.Documents.WorkflowRule do
      public? true
      allow_nil? false
    end
    belongs_to :tag, UniboExPoc.Documents.Tag do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read, :update]
  end

end
