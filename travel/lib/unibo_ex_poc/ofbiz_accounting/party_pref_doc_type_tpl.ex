defmodule UniboExPoc.Ofbiz.Accounting.PartyPrefDocTypeTpl do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "accounting_party_pref_doc_type_tpls"
    repo UniboExPoc.Repo
  end

  graphql do
    type :accounting_party_pref_doc_type_tpl

    queries do
      get :get_accounting_party_pref_doc_type_tpl, :read
      list :list_accounting_party_pref_doc_type_tpls, :read
    end

    mutations do
      create :create_accounting_party_pref_doc_type_tpl, :create
      update :update_accounting_party_pref_doc_type_tpl, :update
      destroy :delete_accounting_party_pref_doc_type_tpl, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :party_pref_doc_type_tpl_id, :string, public?: true
    attribute :from_date, :utc_datetime, public?: true
    attribute :thru_date, :utc_datetime, public?: true
    attribute :order_type_id, :string, public?: true
    attribute :quote_type_id, :string, public?: true
    attribute :custom_screen_id, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :party_acctg_preference, UniboExPoc.Ofbiz.Accounting.PartyAcctgPreference do
      public? true
      source_attribute :party_id
    end
    belongs_to :invoice_type, UniboExPoc.Ofbiz.Accounting.InvoiceType do
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
