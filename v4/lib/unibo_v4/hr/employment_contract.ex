defmodule UniboV4.HR.EmploymentContract do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.HR,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "employment_contracts"
    repo UniboV4.Repo
  end

  graphql do
    type :employment_contract

    queries do
      get :get_employment_contract, :read
      list :list_employment_contracts, :read
    end

    mutations do
      create :create_employment_contract, :create
      update :activate_employment_contract, :activate
      update :terminate_employment_contract, :terminate
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :contract_number, :string, allow_nil?: false
    attribute :contract_type, :atom do
      allow_nil? false
      constraints one_of: [:fixed_term, :permanent, :probation, :internship]
    end
    attribute :start_date, :date, allow_nil?: false
    attribute :end_date, :date
    attribute :salary, :decimal
    attribute :status, :atom do
      constraints one_of: [:draft, :active, :expired, :terminated]
      default :draft
    end
    attribute :notes, :string
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :employee, UniboV4.HR.Employee do
      allow_nil? false
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:contract_number, :contract_type, :start_date, :end_date, :salary, :notes]
      argument :employee_id, :uuid, allow_nil?: false
      change manage_relationship(:employee_id, :employee, type: :append, on_lookup: :relate)
      validate present(:contract_number)
    end
    update :activate do
      accept []
      validate attribute_equals(:status, :draft) do
        message "只有草稿状态可以激活"
      end
      change set_attribute(:status, :active)
    end
    update :terminate do
      accept []
      validate attribute_equals(:status, :active) do
        message "只有激活状态可以终止"
      end
      change set_attribute(:status, :terminated)
    end
  end

  identities do
    identity :unique_contract_number, [:contract_number]
  end

end
