# Workflow: employment_contract_write_flow — EmploymentContract 写操作覆盖流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   activate --> [*]
#   terminate --> [*]
# ```
defmodule UniboExPoc.HR.EmploymentContract do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.HR,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "劳动合同"
  end

  postgres do
    table "hr_employment_contracts"
    repo UniboExPoc.Repo
    identity_index_names unique_contract_number: "idx_hr_employment_contracts_unique_contract_number"
  end

  graphql do
    type :hr_employment_contract

    queries do
      get :get_hr_employment_contract, :read
      list :list_hr_employment_contracts, :read
    end

    mutations do
      create :create_hr_employment_contract, :create
      update :activate_hr_employment_contract, :activate
      update :terminate_hr_employment_contract, :terminate
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :contract_number, :string do
      allow_nil? false
      public? true
      description "合同编号"
    end
    attribute :contract_type, :atom do
      allow_nil? false
      constraints one_of: [:fixed_term, :permanent, :probation, :internship]
      public? true
    end
    attribute :start_date, :date do
      allow_nil? false
      public? true
    end
    attribute :end_date, :date, public?: true
    attribute :salary, :decimal do
      public? true
      description "月薪"
    end
    attribute :status, :atom do
      constraints one_of: [:draft, :active, :expired, :terminated]
      default :draft
      public? true
    end
    attribute :notes, :string, public?: true
    attribute :trial_date_end, :date do
      public? true
      description "试用期结束日"
    end
    attribute :kanban_state, :atom do
      constraints one_of: [:normal, :done, :blocked]
      default :normal
      public? true
    end
    attribute :contract_type_id, :uuid do
      public? true
      description "合同类型"
    end
    attribute :resource_calendar_id, :uuid do
      public? true
      description "工作日历"
    end
    attribute :hr_responsible_id, :uuid do
      public? true
      description "HR负责人"
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
    belongs_to :employee, UniboExPoc.HR.Employee do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read]
    create :create do
      description "Create Employment Contract via Create. doc_url: graphql://contract/hr/create_hr_employment_contract"
      primary? true
      accept [:contract_number, :contract_type, :start_date, :end_date, :salary, :notes]
      argument :employee_id, :uuid, allow_nil?: false
      change manage_relationship(:employee_id, :employee, type: :append, on_lookup: :relate)
      validate present(:contract_number)
    end
    update :activate do
      description "激活合同

激活合同. doc_url: graphql://contract/hr/activate_hr_employment_contract"
      primary? true
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :draft do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :draft}))
        end
      end
      # message: "只有草稿状态可以激活"
      change set_attribute(:status, :active)
      require_atomic? false
    end
    update :terminate do
      description "终止合同

终止合同. doc_url: graphql://contract/hr/terminate_hr_employment_contract"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :active do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :active}))
        end
      end
      # message: "只有激活状态可以终止"
      change set_attribute(:status, :terminated)
      require_atomic? false
    end
  end

  identities do
    identity :unique_contract_number, [:contract_number]
  end

end
