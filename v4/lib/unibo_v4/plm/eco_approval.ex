# Workflow: eco_approval_decision_flow — ECO 审批决策流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> approve
#   create --> reject
#   approve --> [*]
#   reject --> [*]
# ```
defmodule UniboV4.PLM.EcoApproval do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.PLM,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer]

  postgres do
    table "plm_eco_approvals"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :role, :string do
      allow_nil? false
      public? true
    end
    attribute :approval_type, :atom do
      allow_nil? false
      constraints one_of: [:required, :optional, :comment]
      public? true
    end
    attribute :status, :atom do
      constraints one_of: [:pending, :approved, :rejected]
      default :pending
      public? true
    end
    attribute :approval_date, :utc_datetime, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :eco, UniboV4.PLM.Eco do
      public? true
      allow_nil? false
    end
    belongs_to :approver, UniboV4.PLM.User do
      public? true
      allow_nil? false
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
      accept []
      # skipped: validate custom : (incompatible with bulk update atomic path)
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
    update :reject do
      accept []
      # skipped: validate custom : (incompatible with bulk update atomic path)
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
  end

  policies do
    policy action(:approve) do
      authorize_if expr(actor.id == approver_id)
    end
    policy action(:reject) do
      authorize_if expr(actor.id == approver_id)
    end
    policy always() do
      authorize_if always()
    end
  end

end
