defmodule UniboExPoc.Ofbiz.Accounting.PaymentMethodType do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "accounting_payment_method_types"
    repo UniboExPoc.Repo
  end

  graphql do
    type :ofbiz_accounting_payment_method_type

    queries do
      get :get_ofbiz_accounting_payment_method_type, :read
      list :list_ofbiz_accounting_payment_method_types, :read
    end

    mutations do
      create :create_ofbiz_accounting_payment_method_type, :create
      update :update_ofbiz_accounting_payment_method_type, :update
      destroy :delete_ofbiz_accounting_payment_method_type, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :payment_method_type_id, :string, public?: true
    attribute :description, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :default_gl_account, UniboExPoc.Ofbiz.Accounting.GlAccount do
      public? true
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
