defmodule UniboExPoc.Ofbiz.Accounting.InvoiceItemTypeMap do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "accounting_invoice_item_type_maps"
    repo UniboExPoc.Repo
  end

  graphql do
    type :accounting_invoice_item_type_map

    queries do
      get :get_accounting_invoice_item_type_map, :read
      list :list_accounting_invoice_item_type_maps, :read
    end

    mutations do
      create :create_accounting_invoice_item_type_map, :create
      update :update_accounting_invoice_item_type_map, :update
      destroy :delete_accounting_invoice_item_type_map, :destroy
    end

  end

  attributes do
    attribute :invoice_item_map_key, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :invoice_item_type, UniboExPoc.Ofbiz.Accounting.InvoiceItemType do
      public? true
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
