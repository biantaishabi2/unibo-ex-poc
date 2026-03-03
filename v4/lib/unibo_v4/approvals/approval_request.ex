# Workflow: approval_request_approve_flow — 审批请求正常通过流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   submit --> [*]
#   approve --> [*]
# ```
# Workflow: approval_request_refuse_resubmit_flow — 审批请求拒绝后重新提交流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   submit --> [*]
#   refuse --> [*]
#   draft --> [*]
#   submit --> [*]
# ```
# Workflow: approval_request_cancel_flow — 审批请求取消流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   submit --> [*]
#   cancel --> [*]
#   draft --> [*]
# ```
defmodule UniboV4.Approvals.ApprovalRequest do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Approvals,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource],
    notifiers: [UniboV4.Approvals.ApprovalRequest.Notifier]

  postgres do
    table "approvals_approval_requests"
    repo UniboV4.Repo
  end

  graphql do
    type :approvals_approval_request

    queries do
      get :get_approvals_approval_request, :read
      list :list_approvals_approval_requests, :read
    end

    mutations do
      create :create_approvals_approval_request, :create
      update :submit_approvals_approval_request, :submit
      update :approve_approvals_approval_request, :approve
      update :refuse_approvals_approval_request, :refuse
      update :cancel_approvals_approval_request, :cancel
      update :draft_approvals_approval_request, :draft
    end

  end

  attributes do
    attribute :id, :integer do
      primary_key? true
      allow_nil? false
      public? true
    end
    attribute :name, :string do
      allow_nil? false
      public? true
    end
    attribute :category_id, :integer do
      allow_nil? false
      public? true
    end
    attribute :requester_id, :integer do
      allow_nil? false
      public? true
    end
    attribute :status, :atom do
      allow_nil? false
      constraints one_of: [:new, :pending, :approved, :refused, :cancel]
      default :new
      public? true
    end
    attribute :request_date, :date, public?: true
    attribute :date_confirmed, :utc_datetime, public?: true
    attribute :company_id, :integer do
      allow_nil? false
      public? true
    end
    attribute :metadata, :string, public?: true
    attribute :reason, :string, public?: true
    attribute :attachment_ids, {:array, :string}, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  calculations do
    # TODO: 不支持的 calculation 表达式 :approved_count
    # TODO: 不支持的 calculation 表达式 :all_required_approved
  end

  relationships do
    belongs_to :category, UniboV4.Approvals.ApprovalCategory do
      public? true
      allow_nil? false
    end
    belongs_to :requester, UniboV4.Approvals.User do
      public? true
      allow_nil? false
    end
    belongs_to :company, UniboV4.Approvals.Company do
      public? true
      allow_nil? false
    end
    has_many :approvers, UniboV4.Approvals.Approver do
      public? true
      destination_attribute :request_id
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:name, :reason, :metadata, :attachment_ids]
      argument :category_id, :integer, allow_nil?: false
      argument :company_id, :integer, allow_nil?: false
      change manage_relationship(:category_id, :category, type: :append, on_lookup: :relate)
      argument :requester_id, :uuid, allow_nil?: false
      change manage_relationship(:requester_id, :requester, type: :append, on_lookup: :relate)
      change manage_relationship(:company_id, :company, type: :append, on_lookup: :relate)
      argument :approvers, {:array, :map}, default: []
      change manage_relationship(:approvers, :approvers, type: :create)
      validate present(:name)
      change relate_actor(:requester)
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
    end
    update :submit do
      primary? true
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :new do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :new}))
        end
      end
      # message: "只有草稿状态可以提交"
      change set_attribute(:status, :pending)
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
    update :approve do
      accept []
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
      accept []
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
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :pending do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :pending}))
        end
      end
      # message: "只有待审批状态可以取消"
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
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current in [:refused, :cancel] do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must be one of %{values}", vars: %{values: [:refused, :cancel]}))
        end
      end
      # message: "只有拒绝或取消状态可以重置为草稿"
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

end
