defmodule UniboExPoc.Ofbiz.Accounting.AcctgTransEntryType do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "accounting_acctg_trans_entry_types"
    repo UniboExPoc.Repo
  end

  graphql do
    type :ofbiz_accounting_acctg_trans_entry_type

    queries do
      get :get_ofbiz_accounting_acctg_trans_entry_type, :read
      list :list_ofbiz_accounting_acctg_trans_entry_types, :read
    end

    mutations do
      create :create_ofbiz_accounting_acctg_trans_entry_type, :create
      update :update_ofbiz_accounting_acctg_trans_entry_type, :update
      destroy :delete_ofbiz_accounting_acctg_trans_entry_type, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :acctg_trans_entry_type_id, :string, public?: true
    attribute :has_table, :boolean, public?: true
    attribute :description, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :parent_acctg_trans_entry_type, UniboExPoc.Ofbiz.Accounting.AcctgTransEntryType do
      public? true
      source_attribute :parent_type_id
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
