defmodule UniboV4.Documents.WorkflowRuleExcludedTagLink do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Documents,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "documents_workflow_rule_excluded_tag_links"
    repo UniboV4.Repo
  end

  graphql do
    type :documents_workflow_rule_excluded_tag_link

    queries do
      get :get_documents_workflow_rule_excluded_tag_link, :read
      list :list_documents_workflow_rule_excluded_tag_links, :read
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
