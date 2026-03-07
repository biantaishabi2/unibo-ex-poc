defmodule UniboExPoc.Ofbiz.Accounting.InvoiceTerm do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "accounting_invoice_terms"
    repo UniboExPoc.Repo
  end

  graphql do
    type :accounting_invoice_term

    queries do
      get :get_accounting_invoice_term, :read
      list :list_accounting_invoice_terms, :read
    end

    mutations do
      create :create_accounting_invoice_term, :create
      update :update_accounting_invoice_term, :update
      destroy :delete_accounting_invoice_term, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :invoice_term_id, :string, public?: true
    attribute :term_type_id, :string, public?: true
    attribute :invoice_item_seq_id, :string, public?: true
    attribute :term_value, :decimal, public?: true
    attribute :term_days, :integer, public?: true
    attribute :text_value, :string, public?: true
    attribute :description, :string, public?: true
    attribute :uom_id, :string, public?: true
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
