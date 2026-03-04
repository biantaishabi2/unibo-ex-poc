# Workflow: approval_category_lifecycle_flow — 审批类型完整生命周期流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
#   deactivate --> [*]
#   activate --> [*]
# ```
# Workflow: approval_category_deactivate_flow — 审批类型停用流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
#   deactivate --> [*]
# ```
defmodule UniboV4.Approvals.ApprovalCategory do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Approvals,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "approvals_approval_categories"
    repo UniboV4.Repo
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
    attribute :description, :string, public?: true
    attribute :sequence_code, :string, public?: true
    attribute :automated_sequence, :boolean do
      allow_nil? false
      default false
      public? true
    end
    attribute :approval_minimum, :integer do
      allow_nil? false
      public? true
    end
    attribute :manager_approval, :atom do
      allow_nil? false
      constraints one_of: [:required, :optional, :none]
      default :none
      public? true
    end
    attribute :is_active, :boolean do
      allow_nil? false
      default true
      public? true
    end
    attribute :exclusive_user, :boolean do
      allow_nil? false
      default false
      public? true
    end
    attribute :requester_document, :string, public?: true
    attribute :field_config, :string, public?: true
    attribute :approval_mode, :atom do
      constraints one_of: [:parallel, :sequential, :hybrid]
      default :parallel
      public? true
    end
    attribute :routing_rules, :string, public?: true
    attribute :escalation_config, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :company, UniboV4.Approvals.Company do
      public? true
      allow_nil? false
      attribute_type :integer
    end
    has_many :approval_requests, UniboV4.Approvals.ApprovalRequest do
      public? true
      destination_attribute :category_id
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:name, :description, :sequence_code, :automated_sequence, :approval_minimum, :manager_approval, :exclusive_user, :requester_document, :field_config, :approval_mode, :routing_rules, :escalation_config]
      argument :company_id, :integer, allow_nil?: false
      change manage_relationship(:company_id, :company, type: :append, on_lookup: :relate)
      validate present(:name)
      # TODO: 不支持的 action 内校验规则 custom
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
    end
    update :update do
      primary? true
      accept [:name, :description, :sequence_code, :automated_sequence, :approval_minimum, :manager_approval, :exclusive_user, :requester_document, :field_config, :approval_mode, :routing_rules, :escalation_config]
      # skipped: validate custom : (incompatible with bulk update atomic path)
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
    update :activate do
      accept []
      # skipped: validate custom : (incompatible with bulk update atomic path)
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :is_active)
        if current == false do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :is_active, message: "must equal %{value}", vars: %{value: false}))
        end
      end
      # message: "只有停用状态可以启用"
      change set_attribute(:is_active, true)
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
    update :deactivate do
      accept []
      # skipped: validate custom : (incompatible with bulk update atomic path)
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :is_active)
        if current == true do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :is_active, message: "must equal %{value}", vars: %{value: true}))
        end
      end
      # message: "只有启用状态可以停用"
      change set_attribute(:is_active, false)
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

  validations do
    validate compare(:approval_minimum, greater_than_or_equal_to: 0)
  end

  identities do
    identity :unique_name_per_company, [:name, :company_id]
  end

end
