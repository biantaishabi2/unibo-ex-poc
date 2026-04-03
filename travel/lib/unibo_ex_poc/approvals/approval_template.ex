defmodule UniboExPoc.Approvals.ApprovalTemplate do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Approvals,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshStateMachine],
    notifiers: [Ash.Notifier.PubSub]

  resource do
    description "审批模板，定义某类业务发起审批时的基础规则与默认审批人"
  end

  postgres do
    table "approvals_approval_templates"
    repo UniboExPoc.Repo
    identity_index_names unique_template_code: "idx_approvals_approval_templates_unique_template_code"
  end

  graphql do
    type :approvals_approval_template

    queries do
      get :get_approvals_approval_template, :read
      list :list_approvals_approval_templates, :read
    end

    mutations do
      create :create_create_template_approvals_approval_template, :create_template
      update :update_template_approvals_approval_template, :update_template
      update :activate_template_approvals_approval_template, :activate_template
      update :archive_template_approvals_approval_template, :archive_template
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :template_code, :string do
      allow_nil? false
      public? true
      description "模板稳定编码"
    end
    attribute :name, :string do
      allow_nil? false
      public? true
      description "模板名称"
    end
    attribute :subject_type, :string do
      allow_nil? false
      public? true
      description "关联业务对象类型，例如 survey_response、purchase_order"
    end
    attribute :description, :string do
      public? true
      description "模板说明"
    end
    attribute :routing_mode, :atom do
      allow_nil? false
      constraints one_of: [:static, :flow]
      default :static
      public? true
      description "审批模板采用静态默认审批人还是流程定义驱动"
    end
    attribute :template_status, :atom do
      allow_nil? false
      constraints one_of: [:draft, :active, :archived]
      default :draft
      public? true
      description "模板状态"
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
    belongs_to :root_org_party, UniboExPoc.Approvals.Party do
      public? true
      allow_nil? false
    end
    belongs_to :default_approver_party, UniboExPoc.Approvals.Party do
      public? true
    end
    belongs_to :flow_definition, UniboExPoc.Approvals.ApprovalFlowDefinition do
      public? true
    end
    has_many :approval_instances, UniboExPoc.Approvals.ApprovalInstance do
      public? true
      destination_attribute :template_id
    end
  end

  actions do
    defaults [:read]
    create :create_template do
      description "Create Approval Template via Create Template. doc_url: graphql://contract/approvals/create_create_template_approvals_approval_template"
      primary? true
      accept [:template_code, :name, :subject_type, :description, :routing_mode, :root_org_party_id, :default_approver_party_id, :flow_definition_id]
      argument :root_org_party_id, :uuid, allow_nil?: false
      change manage_relationship(:root_org_party_id, :root_org_party, type: :append, on_lookup: :relate)
    end
    update :update_template do
      description "Update Approval Template via Update Template. doc_url: graphql://contract/approvals/update_template_approvals_approval_template"
      primary? true
      accept [:name, :description, :routing_mode, :root_org_party_id, :default_approver_party_id, :flow_definition_id]
      require_atomic? false
    end
    update :activate_template do
      description "Update Approval Template via Activate Template. doc_url: graphql://contract/approvals/activate_template_approvals_approval_template"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :template_status)
        if current == :draft do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :template_status, message: "must equal %{value}", vars: %{value: :draft}))
        end
      end
      # message: "只有草稿模板可以激活"
      change set_attribute(:template_status, :active)
      change AshStateMachine.BuiltinChanges.transition_state(:active)
      require_atomic? false
    end
    update :archive_template do
      description "Update Approval Template via Archive Template. doc_url: graphql://contract/approvals/archive_template_approvals_approval_template"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :template_status)
        if current in [:draft, :active] do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :template_status, message: "must be one of %{values}", vars: %{values: [:draft, :active]}))
        end
      end
      # message: "只有草稿或激活中的模板可以归档"
      change set_attribute(:template_status, :archived)
      change AshStateMachine.BuiltinChanges.transition_state(:archived)
      require_atomic? false
    end
  end

  identities do
    identity :unique_template_code, [:template_code]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end


  state_machine do
    initial_states [:draft]
    default_initial_state :draft
    extra_states [:draft, :active, :archived]
    state_attribute :template_status
    transitions do
      transition :activate_template, from: :draft, to: :active
      transition :archive_template, from: :draft, to: :archived
      transition :archive_template, from: :active, to: :archived
    end
  end

  pub_sub do
    module UniboExPoc.PubSub
    prefix "approval_template"

    publish :activate_template, ["approvals.template.activated"]
    publish :archive_template, ["approvals.template.archived"]
  end
end
