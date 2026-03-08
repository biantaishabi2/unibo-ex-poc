defmodule UniboV4.Ofbiz.Accounting.InvoiceItem do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Ofbiz.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "accounting_invoice_items"
    repo UniboV4.Repo
  end

  graphql do
    type :accounting_invoice_item

    queries do
      get :get_accounting_invoice_item, :read
      list :list_accounting_invoice_items, :read
    end

    mutations do
      create :create_accounting_invoice_item, :create
      update :update_accounting_invoice_item, :update
      destroy :delete_accounting_invoice_item, :destroy
    end

  end

  attributes do
    attribute :invoice_item_seq_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :override_org_party_id, :string do
      public? true
      description "用于指定组织覆盖而不是使用payToPartyId"
    end
    attribute :inventory_item_id, :string, public?: true
    attribute :product_id, :string, public?: true
    attribute :product_feature_id, :string, public?: true
    attribute :parent_invoice_id, :string, public?: true
    attribute :parent_invoice_item_seq_id, :string, public?: true
    attribute :uom_id, :string, public?: true
    attribute :taxable_flag, :boolean, public?: true
    attribute :quantity, :decimal, public?: true
    attribute :amount, :decimal, public?: true
    attribute :description, :string, public?: true
    attribute :tax_auth_party_id, :string, public?: true
    attribute :tax_auth_geo_id, :string, public?: true
    attribute :sales_opportunity_id, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :invoice_item_type, UniboV4.Ofbiz.Accounting.InvoiceItemType do
      public? true
    end
    belongs_to :invoice, UniboV4.Ofbiz.Accounting.Invoice do
      public? true
    end
    belongs_to :override_gl_account, UniboV4.Ofbiz.Accounting.GlAccount do
      public? true
    end
    belongs_to :tax_authority_rate_product, UniboV4.Ofbiz.Accounting.TaxAuthorityRateProduct do
      public? true
      source_attribute :tax_authority_rate_seq_id
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
