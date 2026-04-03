defmodule UniboExPoc.Approvals.ApprovalFlowDefinition do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Approvals,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource]

  resource do
    description "审批流程定义，表达某类审批模板对应的稳定流程标识"
  end

  postgres do
    table "approvals_approval_flow_definitions"
    repo UniboExPoc.Repo
    identity_index_names unique_definition_key: "idx_approvals_approval_flow_definitions_unique_definition_key"
  end

  graphql do
    type :approvals_approval_flow_definition

    queries do
      get :get_approvals_approval_flow_definition, :read
      list :list_approvals_approval_flow_definitions, :read
    end

    mutations do
      create :create_create_definition_approvals_approval_flow_definition, :create_definition
      update :update_definition_approvals_approval_flow_definition, :update_definition
      update :set_active_version_no_approvals_approval_flow_definition, :set_active_version_no
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :definition_key, :string do
      allow_nil? false
      public? true
      description "流程定义稳定编码"
    end
    attribute :name, :string do
      allow_nil? false
      public? true
      description "流程名称"
    end
    attribute :subject_type, :string do
      allow_nil? false
      public? true
      description "适用业务对象类型"
    end
    attribute :active_version_no, :integer do
      public? true
      description "当前启用版本号"
    end
    attribute :inserted_at, :utc_datetime_usec do
      allow_nil? false
      writable? false
      default &DateTime.utc_now/0
      public? true
    end
    attribute :updated_at, :utc_datetime_usec do
      allow_nil? false
      writable? false
      default &DateTime.utc_now/0
      update_default &DateTime.utc_now/0
      public? true
    end
  end

  relationships do
    has_many :versions, UniboExPoc.Approvals.ApprovalFlowVersion do
      public? true
      destination_attribute :flow_definition_id
    end
    has_many :templates, UniboExPoc.Approvals.ApprovalTemplate do
      public? true
      destination_attribute :flow_definition_id
    end
    has_many :instances, UniboExPoc.Approvals.ApprovalInstance do
      public? true
      destination_attribute :flow_definition_id
    end
  end

  actions do
    defaults [:read]
    create :create_definition do
      description "Create Approval Flow Definition via Create Definition. doc_url: graphql://contract/approvals/create_create_definition_approvals_approval_flow_definition"
      primary? true
      accept [:definition_key, :name, :subject_type]
      validate present(:definition_key)
      # message: "流程定义编码不能为空"
    end
    update :update_definition do
      description "Update Approval Flow Definition via Update Definition. doc_url: graphql://contract/approvals/update_definition_approvals_approval_flow_definition"
      primary? true
      accept [:name, :subject_type]
      require_atomic? false
    end
    update :set_active_version_no do
      description "Update Approval Flow Definition via Set Active Version No. doc_url: graphql://contract/approvals/set_active_version_no_approvals_approval_flow_definition"
      accept [:active_version_no]
      require_atomic? false
    end
  end

  identities do
    identity :unique_definition_key, [:definition_key]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
