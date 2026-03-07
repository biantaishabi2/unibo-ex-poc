defmodule UniboExPoc.Ofbiz.Accounting.PartyAcctgPreference do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "accounting_party_acctg_preferences"
    repo UniboExPoc.Repo
  end

  graphql do
    type :accounting_party_acctg_preference

    queries do
      get :get_accounting_party_acctg_preference, :read
      list :list_accounting_party_acctg_preferences, :read
    end

    mutations do
      create :create_accounting_party_acctg_preference, :create
      update :update_accounting_party_acctg_preference, :update
      destroy :delete_accounting_party_acctg_preference, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :party_id, :string, public?: true
    attribute :fiscal_year_start_month, :integer, public?: true
    attribute :fiscal_year_start_day, :integer, public?: true
    attribute :tax_form_id, :string, public?: true
    attribute :cogs_method_id, :string, public?: true
    attribute :base_currency_uom_id, :string, public?: true
    attribute :invoice_seq_cust_meth_id, :string, public?: true
    attribute :invoice_id_prefix, :string, public?: true
    attribute :last_invoice_number, :integer, public?: true
    attribute :last_invoice_restart_date, :utc_datetime, public?: true
    attribute :use_invoice_id_for_returns, :boolean, public?: true
    attribute :quote_seq_cust_meth_id, :string, public?: true
    attribute :quote_id_prefix, :string, public?: true
    attribute :last_quote_number, :integer, public?: true
    attribute :order_seq_cust_meth_id, :string, public?: true
    attribute :order_id_prefix, :string, public?: true
    attribute :last_order_number, :integer, public?: true
    attribute :enable_accounting, :boolean, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :payment_method, UniboExPoc.Ofbiz.Accounting.PaymentMethod do
      public? true
      source_attribute :refund_payment_method_id
    end
    belongs_to :gl_journal, UniboExPoc.Ofbiz.Accounting.GlJournal do
      public? true
      source_attribute :error_gl_journal_id
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
