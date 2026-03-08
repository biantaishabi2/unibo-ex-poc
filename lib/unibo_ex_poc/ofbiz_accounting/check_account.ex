defmodule UniboV4.Ofbiz.Accounting.CheckAccount do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Ofbiz.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "accounting_check_accounts"
    repo UniboV4.Repo
  end

  graphql do
    type :accounting_check_account

    queries do
      get :get_accounting_check_account, :read
      list :list_accounting_check_accounts, :read
    end

    mutations do
      create :create_accounting_check_account, :create
      update :update_accounting_check_account, :update
      destroy :delete_accounting_check_account, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :bank_name, :string, public?: true
    attribute :routing_number, :string do
      public? true
      description "参见 https://en.wikipedia.org/wiki/Bank_code"
    end
    attribute :account_type, :string, public?: true
    attribute :account_number, :string, public?: true
    attribute :name_on_account, :string, public?: true
    attribute :company_name_on_account, :string, public?: true
    attribute :contact_mech_id, :string, public?: true
    attribute :branch_code, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :payment_method, UniboV4.Ofbiz.Accounting.PaymentMethod do
      public? true
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
  end

end
