defmodule UniboExPoc.Ofbiz.Accounting.PayPalPaymentMethod do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "PayPal付款方式详情"
  end

  postgres do
    table "accounting_pay_pal_payment_methods"
    repo UniboExPoc.Repo
  end

  graphql do
    type :accounting_pay_pal_payment_method

    queries do
      get :get_accounting_pay_pal_payment_method, :read
      list :list_accounting_pay_pal_payment_methods, :read
    end

    mutations do
      create :create_accounting_pay_pal_payment_method, :create
      update :update_accounting_pay_pal_payment_method, :update
      destroy :delete_accounting_pay_pal_payment_method, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :payer_id, :string, public?: true
    attribute :express_checkout_token, :string, public?: true
    attribute :payer_status, :string, public?: true
    attribute :avs_addr, :boolean, public?: true
    attribute :avs_zip, :boolean, public?: true
    attribute :correlation_id, :string, public?: true
    attribute :contact_mech_id, :string, public?: true
    attribute :transaction_id, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :payment_method, UniboExPoc.Ofbiz.Accounting.PaymentMethod do
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
