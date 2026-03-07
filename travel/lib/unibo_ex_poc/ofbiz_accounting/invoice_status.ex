defmodule UniboExPoc.Ofbiz.Accounting.InvoiceStatus do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "accounting_invoice_statuses"
    repo UniboExPoc.Repo
  end

  graphql do
    type :accounting_invoice_status

    queries do
      get :get_accounting_invoice_status, :read
      list :list_accounting_invoice_statuss, :read
    end

    mutations do
      create :create_accounting_invoice_status, :create
      update :update_accounting_invoice_status, :update
      destroy :delete_accounting_invoice_status, :destroy
    end

  end

  attributes do
    attribute :status_id, :string do
      allow_nil? false
      primary_key? true
      allow_nil? false
      public? true
    end
    attribute :status_date, :utc_datetime do
      allow_nil? false
      primary_key? true
      allow_nil? false
      public? true
    end
    attribute :change_by_user_login_id, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :invoice, UniboExPoc.Ofbiz.Accounting.Invoice do
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
