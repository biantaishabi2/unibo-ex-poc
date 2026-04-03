defmodule UniboExPoc.Approvals.ApprovalFlowVersion do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Approvals,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshStateMachine],
    notifiers: [Ash.Notifier.PubSub]

  resource do
    description "审批流程版本，冻结节点定义、分支规则与运行时映射快照"
  end

  postgres do
    table "approvals_approval_flow_versions"
    repo UniboExPoc.Repo
    identity_index_names unique_version_no_in_definition: "idx_approvals_approval_flow_versions_unique_version_no_aa120627"
  end

  graphql do
    type :approvals_approval_flow_version

    queries do
      get :get_approvals_approval_flow_version, :read
      list :list_approvals_approval_flow_versions, :read
    end

    mutations do
      create :create_create_version_approvals_approval_flow_version, :create_version
      update :activate_version_approvals_approval_flow_version, :activate_version
      update :retire_version_approvals_approval_flow_version, :retire_version
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :version_no, :integer do
      allow_nil? false
      public? true
      description "版本号，从 1 开始递增"
    end
    attribute :version_status, :atom do
      allow_nil? false
      constraints one_of: [:draft, :active, :retired]
      default :draft
      public? true
      description "版本状态"
    end
    attribute :flow_snapshot, :map do
      allow_nil? false
      public? true
      description "节点定义、条件分支、并行配置、抄送配置与运行时快照（JSON 存多步骤/条件/并行）"
    end
    attribute :published_at, :utc_datetime do
      public? true
      description "启用时间"
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
    belongs_to :flow_definition, UniboExPoc.Approvals.ApprovalFlowDefinition do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read]
    create :create_version do
      description "Create Approval Flow Version via Create Version. doc_url: graphql://contract/approvals/create_create_version_approvals_approval_flow_version"
      primary? true
      accept [:version_no, :flow_snapshot, :flow_definition_id]
      argument :flow_definition_id, :uuid, allow_nil?: false
      change manage_relationship(:flow_definition_id, :flow_definition, type: :append, on_lookup: :relate)
      validate compare(:version_no, greater_than_or_equal_to: 1)
      # message: "版本号必须大于等于 1"
    end
    update :activate_version do
      description "Update Approval Flow Version via Activate Version. doc_url: graphql://contract/approvals/activate_version_approvals_approval_flow_version"
      primary? true
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :version_status)
        if current == :draft do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :version_status, message: "must equal %{value}", vars: %{value: :draft}))
        end
      end
      # message: "只有草稿版本可以激活"
      change set_attribute(:version_status, :active)
      change set_attribute(:published_at, &DateTime.utc_now/0)
      change AshStateMachine.BuiltinChanges.transition_state(:active)
      require_atomic? false
    end
    update :retire_version do
      description "Update Approval Flow Version via Retire Version. doc_url: graphql://contract/approvals/retire_version_approvals_approval_flow_version"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :version_status)
        if current == :active do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :version_status, message: "must equal %{value}", vars: %{value: :active}))
        end
      end
      # message: "只有激活版本可以退役"
      change set_attribute(:version_status, :retired)
      change AshStateMachine.BuiltinChanges.transition_state(:retired)
      require_atomic? false
    end
  end

  identities do
    identity :unique_version_no_in_definition, [:flow_definition_id, :version_no]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end


  state_machine do
    initial_states [:draft]
    default_initial_state :draft
    extra_states [:draft, :active, :retired]
    state_attribute :version_status
    transitions do
      transition :activate_version, from: :draft, to: :active
      transition :retire_version, from: :active, to: :retired
    end
  end

  pub_sub do
    module UniboExPoc.PubSub
    prefix "approval_flow_version"

    publish :activate_version, ["approvals.flow_version.activated"]
    publish :retire_version, ["approvals.flow_version.retired"]
  end
end
