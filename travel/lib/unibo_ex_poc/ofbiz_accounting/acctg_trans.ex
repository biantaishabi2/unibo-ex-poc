defmodule UniboExPoc.Ofbiz.Accounting.AcctgTrans do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "accounting_acctg_transes"
    repo UniboExPoc.Repo
  end

  graphql do
    type :ofbiz_accounting_acctg_trans

    queries do
      get :get_ofbiz_accounting_acctg_trans, :read
      list :list_ofbiz_accounting_acctg_transs, :read
    end

    mutations do
      create :create_ofbiz_accounting_acctg_trans, :create
      update :update_ofbiz_accounting_acctg_trans, :update
      destroy :delete_ofbiz_accounting_acctg_trans, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :acctg_trans_id, :string, public?: true
    attribute :description, :string, public?: true
    attribute :transaction_date, :utc_datetime, public?: true
    attribute :is_posted, :boolean, public?: true
    attribute :posted_date, :utc_datetime, public?: true
    attribute :scheduled_posting_date, :utc_datetime, public?: true
    attribute :voucher_ref, :string, public?: true
    attribute :voucher_date, :utc_datetime, public?: true
    attribute :group_status_id, :string, public?: true
    attribute :inventory_item_id, :string, public?: true
    attribute :physical_inventory_id, :string, public?: true
    attribute :party_id, :string, public?: true
    attribute :role_type_id, :string, public?: true
    attribute :shipment_id, :string, public?: true
    attribute :receipt_id, :string, public?: true
    attribute :work_effort_id, :string, public?: true
    attribute :their_acctg_trans_id, :string, public?: true
    attribute :created_date, :utc_datetime, public?: true
    attribute :created_by_user_login, :string, public?: true
    attribute :last_modified_date, :utc_datetime, public?: true
    attribute :last_modified_by_user_login, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :acctg_trans_type, UniboExPoc.Ofbiz.Accounting.AcctgTransType do
      public? true
    end
    belongs_to :gl_journal, UniboExPoc.Ofbiz.Accounting.GlJournal do
      public? true
    end
    belongs_to :gl_fiscal_type, UniboExPoc.Ofbiz.Accounting.GlFiscalType do
      public? true
    end
    belongs_to :fixed_asset, UniboExPoc.Ofbiz.Accounting.FixedAsset do
      public? true
    end
    belongs_to :invoice, UniboExPoc.Ofbiz.Accounting.Invoice do
      public? true
    end
    belongs_to :payment, UniboExPoc.Ofbiz.Accounting.Payment do
      public? true
    end
    belongs_to :fin_account_trans, UniboExPoc.Ofbiz.Accounting.FinAccountTrans do
      public? true
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
