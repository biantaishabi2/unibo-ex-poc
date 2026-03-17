defmodule UniboExPoc.Ofbiz.Accounting.GlFiscalType do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "accounting_gl_fiscal_types"
    repo UniboExPoc.Repo
  end

  graphql do
    type :ofbiz_accounting_gl_fiscal_type

    queries do
      get :get_ofbiz_accounting_gl_fiscal_type, :read
      list :list_ofbiz_accounting_gl_fiscal_types, :read
    end

    mutations do
      create :create_ofbiz_accounting_gl_fiscal_type, :create
      update :update_ofbiz_accounting_gl_fiscal_type, :update
      destroy :delete_ofbiz_accounting_gl_fiscal_type, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :gl_fiscal_type_id, :string, public?: true
    attribute :description, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
