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
defmodule UniboV4.Approvals.Approver do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Approvals,
    data_layer: AshPostgres.DataLayer,
    notifiers: [UniboV4.Approvals.Approver.Notifier]

  postgres do
    table "approvals_approvers"
    repo UniboV4.Repo
  end

  attributes do
    attribute :id, :integer do
      primary_key? true
      allow_nil? false
      public? true
    end
    attribute :status, :atom do
      allow_nil? false
      constraints one_of: [:new, :pending, :approved, :refused, :cancel]
      default :new
      public? true
    end
    attribute :required, :boolean do
      allow_nil? false
      default false
      public? true
    end
    attribute :role, :string, public?: true
    attribute :comment, :string, public?: true
    attribute :approval_date, :utc_datetime, public?: true
    attribute :can_edit, :boolean do
      allow_nil? false
      default false
      public? true
    end
    attribute :sequence_order, :integer, public?: true
    attribute :delegation_state, :atom do
      constraints one_of: [:pending, :resolved]
      public? true
    end
    attribute :escalated_from_id, :integer, public?: true
    attribute :deadline, :utc_datetime, public?: true
  end

  relationships do
    belongs_to :user, UniboV4.Approvals.User do
      public? true
      allow_nil? false
    end
    belongs_to :request, UniboV4.Approvals.ApprovalRequest do
      public? true
      allow_nil? false
      attribute_type :integer
    end
    belongs_to :delegated_from, UniboV4.Approvals.User do
      public? true
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:required, :role, :can_edit, :sequence_order]
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
      # TODO: 跨实体聚合表达式暂不支持
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
      # TODO: 跨实体聚合表达式暂不支持
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

end
