# Workflow: approver_approve_flow — 审批人通过流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   approve --> [*]
# ```
# Workflow: approver_refuse_flow — 审批人拒绝流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   refuse --> [*]
# ```
# Workflow: approver_cancel_reset_flow — 审批人取消并重置流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   cancel --> [*]
#   draft --> [*]
# ```
defmodule UniboExPoc.Approvals.Approver do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Approvals,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource],
    notifiers: [UniboExPoc.Approvals.Approver.Notifier]

  resource do
    description "审批人记录，跟踪每个审批人对请求的审批状态"
  end

  postgres do
    table "approvals_approvers"
    repo UniboExPoc.Repo
  end

  graphql do
    type :approvals_approver

    queries do
      get :get_approvals_approver, :read
      list :list_approvals_approvers, :read
    end

    mutations do
      create :create_approvals_approver, :create
      update :approve_approvals_approver, :approve
      update :refuse_approvals_approver, :refuse
      update :cancel_approvals_approver, :cancel
      update :draft_approvals_approver, :draft
    end

  end

  attributes do
    attribute :id, :integer do
      primary_key? true
      allow_nil? false
      generated? true
      public? true
    end
    attribute :status, :atom do
      allow_nil? false
      constraints one_of: [:new, :pending, :approved, :refused, :cancel]
      default :new
      public? true
      description "审批人状态"
    end
    attribute :required, :boolean do
      allow_nil? false
      default false
      public? true
      description "是否为必须审批人"
    end
    attribute :role, :string do
      public? true
      description "审批人角色（如 direct_manager）"
    end
    attribute :comment, :string do
      public? true
      description "审批意见（refuse 时填写）"
    end
    attribute :approval_date, :utc_datetime do
      public? true
      description "做出决定的时间"
    end
    attribute :can_edit, :boolean do
      allow_nil? false
      default false
      public? true
      description "是否可编辑请求内容"
    end
    attribute :sequence_order, :integer do
      public? true
      description "串行审批时的执行顺序（Phase 2）"
    end
    attribute :delegation_state, :atom do
      constraints one_of: [:pending, :resolved]
      public? true
      description "委派状态（Phase 2）"
    end
    attribute :escalated_from_id, :integer do
      public? true
      description "升级来源审批记录（Phase 3）"
    end
    attribute :deadline, :utc_datetime do
      public? true
      description "审批截止时间（Phase 3）"
    end
  end

  relationships do
    belongs_to :user, UniboExPoc.Approvals.Party do
      public? true
      allow_nil? false
      source_attribute :user_party_id
    end
    belongs_to :request, UniboExPoc.Approvals.ApprovalRequest do
      public? true
      allow_nil? false
      attribute_type :integer
    end
    belongs_to :delegated_from, UniboExPoc.Approvals.Party do
      public? true
      source_attribute :delegated_from_party_id
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:required, :role, :can_edit, :sequence_order]
      argument :user_id, :uuid
      argument :request_id, :integer, allow_nil?: false
      argument :user_id, :uuid, allow_nil?: false
      change manage_relationship(:user_id, :user, type: :append, on_lookup: :relate)
      change manage_relationship(:request_id, :request, type: :append, on_lookup: :relate)
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
    end
    update :approve do
      description "审批通过"
      primary? true
      accept [:comment]
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :pending do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :pending}))
        end
      end
      # message: "只有待审批状态可以通过"
      change set_attribute(:status, :approved)
      change UniboExPoc.Approvals.Changes.Approver.ComputeApprovalDate
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
      require_atomic? false
    end
    update :refuse do
      description "审批拒绝"
      accept [:comment]
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :pending do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :pending}))
        end
      end
      # message: "只有待审批状态可以拒绝"
      change set_attribute(:status, :refused)
      change UniboExPoc.Approvals.Changes.Approver.ComputeApprovalDate
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
      require_atomic? false
    end
    update :cancel do
      description "取消（随 request 取消批量设置）"
      accept []
      change set_attribute(:status, :cancel)
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
      require_atomic? false
    end
    update :draft do
      description "重置为初始状态（随 request 重置批量设置）"
      accept []
      change set_attribute(:status, :new)
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
      require_atomic? false
    end
  end

  identities do
    identity :unique_user_per_request, [:request_id, :user_id]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
