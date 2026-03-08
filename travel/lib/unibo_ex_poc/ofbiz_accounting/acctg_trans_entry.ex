defmodule UniboExPoc.Ofbiz.Accounting.AcctgTransEntry do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "accounting_acctg_trans_entries"
    repo UniboExPoc.Repo
  end

  graphql do
    type :accounting_acctg_trans_entry

    queries do
      get :get_accounting_acctg_trans_entry, :read
      list :list_accounting_acctg_trans_entrys, :read
    end

    mutations do
      create :create_accounting_acctg_trans_entry, :create
      update :update_accounting_acctg_trans_entry, :update
      destroy :delete_accounting_acctg_trans_entry, :destroy
    end

  end

  attributes do
    attribute :acctg_trans_entry_seq_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :description, :string, public?: true
    attribute :voucher_ref, :string, public?: true
    attribute :party_id, :string, public?: true
    attribute :role_type_id, :string, public?: true
    attribute :their_party_id, :string, public?: true
    attribute :product_id, :string, public?: true
    attribute :their_product_id, :string, public?: true
    attribute :inventory_item_id, :string, public?: true
    attribute :organization_party_id, :string, public?: true
    attribute :amount, :decimal, public?: true
    attribute :currency_uom_id, :string, public?: true
    attribute :orig_amount, :decimal, public?: true
    attribute :orig_currency_uom_id, :string, public?: true
    attribute :debit_credit_flag, :boolean, public?: true
    attribute :due_date, :utc_datetime, public?: true
    attribute :group_id, :string, public?: true
    attribute :tax_id, :string, public?: true
    attribute :reconcile_status_id, :string, public?: true
    attribute :is_summary, :boolean, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :acctg_trans_entry_type, UniboExPoc.Ofbiz.Accounting.AcctgTransEntryType do
      public? true
    end
    belongs_to :acctg_trans, UniboExPoc.Ofbiz.Accounting.AcctgTrans do
      public? true
    end
    belongs_to :gl_account_type, UniboExPoc.Ofbiz.Accounting.GlAccountType do
      public? true
    end
    belongs_to :gl_account, UniboExPoc.Ofbiz.Accounting.GlAccount do
      public? true
    end
    belongs_to :settlement_term, UniboExPoc.Ofbiz.Accounting.SettlementTerm do
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
