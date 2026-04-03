# Workflow: bank_account_write_flow — BankAccount 写操作覆盖流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
# ```
defmodule UniboExPoc.HR.BankAccount do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.HR,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "员工银行账户"
  end

  postgres do
    table "hr_bank_accounts"
    repo UniboExPoc.Repo
  end

  graphql do
    type :hr_bank_account

    queries do
      get :get_hr_bank_account, :read
      list :list_hr_bank_accounts, :read
    end

    mutations do
      create :create_hr_bank_account, :create
      update :update_hr_bank_account, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :bank_name, :string do
      allow_nil? false
      public? true
      description "开户银行"
    end
    attribute :account_number, :string do
      allow_nil? false
      public? true
      description "银行账号"
    end
    attribute :account_holder, :string do
      public? true
      description "账户持有人姓名"
    end
    attribute :is_primary, :boolean do
      default true
      public? true
      description "是否为主账户"
    end
    attribute :swift_code, :string do
      public? true
      description "SWIFT 代码（跨境支付）"
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
      description "Create Bank Account via Create. doc_url: graphql://contract/hr/create_hr_bank_account"
      primary? true
      accept [:bank_name, :account_number, :account_holder, :is_primary, :swift_code]
      argument :employee_id, :uuid, allow_nil?: false
      change manage_relationship(:employee_id, :employee, type: :append, on_lookup: :relate)
      validate present(:bank_name)
      validate present(:account_number)
    end
    update :update do
      description "Update Bank Account via Update. doc_url: graphql://contract/hr/update_hr_bank_account"
      primary? true
      accept [:bank_name, :account_number, :account_holder, :is_primary, :swift_code]
      require_atomic? false
    end
  end

end
