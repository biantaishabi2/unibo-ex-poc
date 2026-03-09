defmodule UniboExPoc.Ofbiz.Accounting.PaymentGatewayRespMsg do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Accounting,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "accounting_payment_gateway_resp_msgs"
    repo UniboExPoc.Repo
  end

  graphql do
    type :accounting_payment_gateway_resp_msg

    queries do
      get :get_accounting_payment_gateway_resp_msg, :read
      list :list_accounting_payment_gateway_resp_msgs, :read
    end

    mutations do
      create :create_accounting_payment_gateway_resp_msg, :create
      update :update_accounting_payment_gateway_resp_msg, :update
      destroy :delete_accounting_payment_gateway_resp_msg, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :payment_gateway_resp_msg_id, :string, public?: true
    attribute :pgr_message, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :payment_gateway_response, UniboExPoc.Ofbiz.Accounting.PaymentGatewayResponse do
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
