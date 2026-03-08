defmodule UniboV4.Ofbiz.Accounting.PaymentGatewayConfig do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Ofbiz.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "accounting_payment_gateway_configs"
    repo UniboV4.Repo
  end

  graphql do
    type :accounting_payment_gateway_config

    queries do
      get :get_accounting_payment_gateway_config, :read
      list :list_accounting_payment_gateway_configs, :read
    end

    mutations do
      create :create_accounting_payment_gateway_config, :create
      update :update_accounting_payment_gateway_config, :update
      destroy :delete_accounting_payment_gateway_config, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :payment_gateway_config_id, :string, public?: true
    attribute :description, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :payment_gateway_config_type, UniboV4.Ofbiz.Accounting.PaymentGatewayConfigType do
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
