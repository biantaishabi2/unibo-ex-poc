defmodule UniboExPoc.Ofbiz.Accounting.ZipSalesTaxLookup do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "accounting_zip_sales_tax_lookups"
    repo UniboExPoc.Repo
  end

  graphql do
    type :accounting_zip_sales_tax_lookup

    queries do
      get :get_accounting_zip_sales_tax_lookup, :read
      list :list_accounting_zip_sales_tax_lookups, :read
    end

    mutations do
      create :create_accounting_zip_sales_tax_lookup, :create
      update :update_accounting_zip_sales_tax_lookup, :update
      destroy :delete_accounting_zip_sales_tax_lookup, :destroy
    end

  end

  attributes do
    attribute :zip_code, :string do
      allow_nil? false
      primary_key? true
      allow_nil? false
      public? true
    end
    attribute :state_code, :string do
      allow_nil? false
      primary_key? true
      allow_nil? false
      public? true
    end
    attribute :city, :string do
      allow_nil? false
      primary_key? true
      allow_nil? false
      public? true
    end
    attribute :county, :string do
      allow_nil? false
      primary_key? true
      allow_nil? false
      public? true
    end
    attribute :from_date, :utc_datetime do
      allow_nil? false
      primary_key? true
      allow_nil? false
      public? true
    end
    attribute :county_fips, :string, public?: true
    attribute :county_default, :boolean, public?: true
    attribute :general_default, :boolean, public?: true
    attribute :inside_city, :boolean, public?: true
    attribute :geo_code, :string, public?: true
    attribute :state_sales_tax, :decimal, public?: true
    attribute :city_sales_tax, :decimal, public?: true
    attribute :city_local_sales_tax, :decimal, public?: true
    attribute :county_sales_tax, :decimal, public?: true
    attribute :county_local_sales_tax, :decimal, public?: true
    attribute :combo_sales_tax, :decimal, public?: true
    attribute :state_use_tax, :decimal, public?: true
    attribute :city_use_tax, :decimal, public?: true
    attribute :city_local_use_tax, :decimal, public?: true
    attribute :county_use_tax, :decimal, public?: true
    attribute :county_local_use_tax, :decimal, public?: true
    attribute :combo_use_tax, :decimal, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
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
