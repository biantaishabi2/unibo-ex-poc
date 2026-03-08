defmodule UniboV4.Ofbiz.Accounting.BillingAccountTermAttr do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Ofbiz.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "accounting_billing_account_term_attrs"
    repo UniboV4.Repo
  end

  graphql do
    type :accounting_billing_account_term_attr

    queries do
      get :get_accounting_billing_account_term_attr, :read
      list :list_accounting_billing_account_term_attrs, :read
    end

    mutations do
      create :create_accounting_billing_account_term_attr, :create
      update :update_accounting_billing_account_term_attr, :update
      destroy :delete_accounting_billing_account_term_attr, :destroy
    end

  end

  attributes do
    attribute :attr_name, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :attr_value, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :billing_account_term, UniboV4.Ofbiz.Accounting.BillingAccountTerm do
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
