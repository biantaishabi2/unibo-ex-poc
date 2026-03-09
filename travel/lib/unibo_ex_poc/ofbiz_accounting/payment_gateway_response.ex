defmodule UniboExPoc.Ofbiz.Accounting.PaymentGatewayResponse do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "accounting_payment_gateway_responses"
    repo UniboExPoc.Repo
  end

  graphql do
    type :ofbiz_accounting_payment_gateway_response

    queries do
      get :get_ofbiz_accounting_payment_gateway_response, :read
      list :list_ofbiz_accounting_payment_gateway_responses, :read
    end

    mutations do
      create :create_ofbiz_accounting_payment_gateway_response, :create
      update :update_ofbiz_accounting_payment_gateway_response, :update
      destroy :delete_ofbiz_accounting_payment_gateway_response, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :payment_gateway_response_id, :string, public?: true
    attribute :payment_service_type_enum_id, :string, public?: true
    attribute :order_payment_preference_id, :string, public?: true
    attribute :trans_code_enum_id, :string, public?: true
    attribute :amount, :decimal, public?: true
    attribute :currency_uom_id, :string, public?: true
    attribute :reference_num, :string, public?: true
    attribute :alt_reference, :string, public?: true
    attribute :sub_reference, :string, public?: true
    attribute :gateway_code, :string, public?: true
    attribute :gateway_flag, :string, public?: true
    attribute :gateway_avs_result, :string, public?: true
    attribute :gateway_cv_result, :string, public?: true
    attribute :gateway_score_result, :string, public?: true
    attribute :gateway_message, :string, public?: true
    attribute :transaction_date, :utc_datetime, public?: true
    attribute :result_declined, :boolean, public?: true
    attribute :result_nsf, :boolean, public?: true
    attribute :result_bad_expire, :boolean, public?: true
    attribute :result_bad_card_number, :boolean, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :payment_method_type, UniboExPoc.Ofbiz.Accounting.PaymentMethodType do
      public? true
    end
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
