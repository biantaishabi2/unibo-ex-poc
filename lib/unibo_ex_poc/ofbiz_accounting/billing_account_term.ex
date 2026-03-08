defmodule UniboV4.Ofbiz.Accounting.BillingAccountTerm do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Ofbiz.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "accounting_billing_account_terms"
    repo UniboV4.Repo
  end

  graphql do
    type :accounting_billing_account_term

    queries do
      get :get_accounting_billing_account_term, :read
      list :list_accounting_billing_account_terms, :read
    end

    mutations do
      create :create_accounting_billing_account_term, :create
      update :update_accounting_billing_account_term, :update
      destroy :delete_accounting_billing_account_term, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :billing_account_term_id, :string, public?: true
    attribute :term_type_id, :string, public?: true
    attribute :term_value, :decimal, public?: true
    attribute :term_days, :integer, public?: true
    attribute :uom_id, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :billing_account, UniboV4.Ofbiz.Accounting.BillingAccount do
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
