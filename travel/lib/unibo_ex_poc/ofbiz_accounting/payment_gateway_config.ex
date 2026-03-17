defmodule UniboExPoc.Ofbiz.Accounting.PaymentGatewayConfig do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  postgres do
    table "accounting_payment_gateway_configs"
    repo UniboExPoc.Repo
  end

  graphql do
    type :ofbiz_accounting_payment_gateway_config

    queries do
      get :get_ofbiz_accounting_payment_gateway_config, :read
      list :list_ofbiz_accounting_payment_gateway_configs, :read
    end

    mutations do
      create :create_ofbiz_accounting_payment_gateway_config, :create
      update :update_ofbiz_accounting_payment_gateway_config, :update
      destroy :delete_ofbiz_accounting_payment_gateway_config, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :payment_gateway_config_id, :string, public?: true
    attribute :description, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :payment_gateway_config_type, UniboExPoc.Ofbiz.Accounting.PaymentGatewayConfigType do
      public? true
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
