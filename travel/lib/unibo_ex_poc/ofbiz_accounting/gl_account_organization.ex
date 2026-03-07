defmodule UniboExPoc.Ofbiz.Accounting.GlAccountOrganization do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "accounting_gl_account_organizations"
    repo UniboExPoc.Repo
  end

  graphql do
    type :accounting_gl_account_organization

    queries do
      get :get_accounting_gl_account_organization, :read
      list :list_accounting_gl_account_organizations, :read
    end

    mutations do
      create :create_accounting_gl_account_organization, :create
      update :update_accounting_gl_account_organization, :update
      destroy :delete_accounting_gl_account_organization, :destroy
    end

  end

  attributes do
    attribute :organization_party_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :role_type_id, :string, public?: true
    attribute :from_date, :utc_datetime, public?: true
    attribute :thru_date, :utc_datetime, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :gl_account, UniboExPoc.Ofbiz.Accounting.GlAccount do
      public? true
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
