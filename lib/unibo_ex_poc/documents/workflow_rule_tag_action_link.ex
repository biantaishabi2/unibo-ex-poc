defmodule UniboV4.Documents.WorkflowRuleTagActionLink do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Documents,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "工作流规则-添加标签桥接占位实体"
  end

  postgres do
    table "documents_workflow_rule_tag_action_links"
    repo UniboV4.Repo
  end

  graphql do
    type :documents_workflow_rule_tag_action_link

    queries do
      get :get_documents_workflow_rule_tag_action_link, :read
      list :list_documents_workflow_rule_tag_action_links, :read
    end

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
    defaults [:read, :update]
  end

end
