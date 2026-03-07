defmodule UniboExPoc.Ofbiz.Accounting.PaymentGatewayEway do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "accounting_payment_gateway_eways"
    repo UniboExPoc.Repo
  end

  graphql do
    type :accounting_payment_gateway_eway

    queries do
      get :get_accounting_payment_gateway_eway, :read
      list :list_accounting_payment_gateway_eways, :read
    end

    mutations do
      create :create_accounting_payment_gateway_eway, :create
      update :update_accounting_payment_gateway_eway, :update
      destroy :delete_accounting_payment_gateway_eway, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :customer_id, :string, public?: true
    attribute :refund_pwd, :string, public?: true
    attribute :test_mode, :string, public?: true
    attribute :enable_cvn, :string, public?: true
    attribute :enable_beagle, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :payment_gateway_config, UniboExPoc.Ofbiz.Accounting.PaymentGatewayConfig do
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
