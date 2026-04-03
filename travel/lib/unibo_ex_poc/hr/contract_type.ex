# Workflow: contract_type_write_flow — ContractType 写操作覆盖流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
# ```
defmodule UniboExPoc.HR.ContractType do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.HR,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "合同类型"
  end

  postgres do
    table "hr_contract_types"
    repo UniboExPoc.Repo
  end

  graphql do
    type :hr_contract_type

    queries do
      get :get_hr_contract_type, :read
      list :list_hr_contract_types, :read
    end

    mutations do
      create :create_hr_contract_type, :create
      update :update_hr_contract_type, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
    end
    attribute :code, :string, public?: true
    attribute :country, :string, public?: true
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
    has_many :contracts, UniboExPoc.HR.EmploymentContract do
      public? true
      destination_attribute :contract_type_id
    end
  end

  actions do
    defaults [:read]
    create :create do
      description "Create Contract Type via Create. doc_url: graphql://contract/hr/create_hr_contract_type"
      primary? true
      accept [:name, :code, :country]
      validate present(:name)
    end
    update :update do
      description "Update Contract Type via Update. doc_url: graphql://contract/hr/update_hr_contract_type"
      primary? true
      accept [:name, :code, :country]
      require_atomic? false
    end
  end

end
