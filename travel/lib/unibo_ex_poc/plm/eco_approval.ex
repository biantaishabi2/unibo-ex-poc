# Workflow: eco_approval_decision_flow — ECO 审批决策流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> approve
#   create --> reject
#   approve --> [*]
#   reject --> [*]
# ```
defmodule UniboExPoc.PLM.EcoApproval do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.PLM,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource],
    authorizers: [Ash.Policy.Authorizer]

  resource do
    description "ECO 审批记录，pending→approved/rejected（不可逆）"
  end

  postgres do
    table "plm_eco_approvals"
    repo UniboExPoc.Repo
  end

  graphql do
    type :plm_eco_approval

    queries do
      get :get_plm_eco_approval, :read
      list :list_plm_eco_approvals, :read
    end

    mutations do
      create :create_plm_eco_approval, :create
      update :approve_plm_eco_approval, :approve
      update :reject_plm_eco_approval, :reject
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :role, :string do
      allow_nil? false
      public? true
      description "审批角色（工程经理 / 质量经理等）"
    end
    attribute :approval_type, :atom do
      allow_nil? false
      constraints one_of: [:required, :optional, :comment]
      public? true
      description "审批类型：required=必须 / optional=可选 / comment=仅评论"
    end
    attribute :status, :atom do
      constraints one_of: [:pending, :approved, :rejected]
      default :pending
      public? true
      description "审批状态（pending → approved / rejected，不可逆）"
    end
    attribute :approval_date, :utc_datetime do
      public? true
      description "审批完成时写入"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :eco, UniboExPoc.PLM.Eco do
      public? true
      allow_nil? false
    end
    belongs_to :approver, UniboExPoc.PLM.Party do
      public? true
      allow_nil? false
      source_attribute :approver_party_id
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:role, :approval_type]
      argument :eco_id, :uuid, allow_nil?: false
      argument :approver_id, :uuid, allow_nil?: false
      change manage_relationship(:eco_id, :eco, type: :append, on_lookup: :relate)
      change manage_relationship(:approver_id, :approver, type: :append, on_lookup: :relate)
      change set_attribute(:id, expr(id))
    end
    update :approve do
      description "审批通过（不可逆）"
      primary? true
      accept []
      # skipped: validate policy_check : (incompatible with bulk update atomic path)
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
      change UniboExPoc.PLM.Changes.EcoApproval.ComputeApprovalDate
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :reject do
      description "审批拒绝（不可逆）"
      accept []
      # skipped: validate policy_check : (incompatible with bulk update atomic path)
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :pending do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :pending}))
        end
      end
      # message: "只有待审批状态可以拒绝"
      change set_attribute(:status, :rejected)
      change UniboExPoc.PLM.Changes.EcoApproval.ComputeApprovalDate
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  policies do
    policy action(:approve) do
      authorize_if expr(actor.id == approver_id)
    end
    policy action(:reject) do
      authorize_if expr(actor.id == approver_id)
    end
  end

end
