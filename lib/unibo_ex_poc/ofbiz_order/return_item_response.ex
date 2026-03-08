defmodule UniboV4.Ofbiz.Order.ReturnItemResponse do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Ofbiz.Order,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "记录对退回所做的处理：是否签发了替换订单、付款或账单账户信用"
  end

  postgres do
    table "order_return_item_responses"
    repo UniboV4.Repo
  end

  graphql do
    type :order_return_item_response

    queries do
      get :get_order_return_item_response, :read
      list :list_order_return_item_responses, :read
    end

    mutations do
      create :create_order_return_item_response, :create
      update :update_order_return_item_response, :update
      destroy :delete_order_return_item_response, :destroy
    end

  end

  attributes do
    attribute :id, :string do
      primary_key? true
      allow_nil? false
      public? true
    end
    attribute :return_item_response_id, :string, public?: true
    attribute :payment_id, :string, public?: true
    attribute :billing_account_id, :string, public?: true
    attribute :fin_account_trans_id, :string, public?: true
    attribute :response_amount, :decimal, public?: true
    attribute :response_date, :utc_datetime, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :order_payment_preference, UniboV4.Ofbiz.Order.OrderPaymentPreference do
      public? true
      attribute_type :string
    end
    belongs_to :replacement_order_header, UniboV4.Ofbiz.Order.OrderHeader do
      public? true
      source_attribute :replacement_order_id
      attribute_type :string
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
