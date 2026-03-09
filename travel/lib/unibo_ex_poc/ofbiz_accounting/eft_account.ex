defmodule UniboExPoc.Ofbiz.Accounting.EftAccount do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "accounting_eft_accounts"
    repo UniboExPoc.Repo
  end

  graphql do
    type :ofbiz_accounting_eft_account

    queries do
      get :get_ofbiz_accounting_eft_account, :read
      list :list_ofbiz_accounting_eft_accounts, :read
    end

    mutations do
      create :create_ofbiz_accounting_eft_account, :create
      update :update_ofbiz_accounting_eft_account, :update
      destroy :delete_ofbiz_accounting_eft_account, :destroy
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
    attribute :years_at_bank, :integer, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :payment_method, UniboExPoc.Ofbiz.Accounting.PaymentMethod do
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
