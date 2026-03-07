defmodule UniboExPoc.Ofbiz.Accounting.ZipSalesRuleLookup do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "accounting_zip_sales_rule_lookups"
    repo UniboExPoc.Repo
  end

  graphql do
    type :accounting_zip_sales_rule_lookup

    queries do
      get :get_accounting_zip_sales_rule_lookup, :read
      list :list_accounting_zip_sales_rule_lookups, :read
    end

    mutations do
      create :create_accounting_zip_sales_rule_lookup, :create
      update :update_accounting_zip_sales_rule_lookup, :update
      destroy :delete_accounting_zip_sales_rule_lookup, :destroy
    end

  end

  attributes do
    attribute :state_code, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :city, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :county, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :from_date, :utc_datetime do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :id_code, :string, public?: true
    attribute :taxable, :string, public?: true
    attribute :ship_cond, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
