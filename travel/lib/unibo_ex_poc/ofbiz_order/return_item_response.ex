defmodule UniboExPoc.Ofbiz.Order.ReturnItemResponse do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Order,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshArchival.Resource]

  resource do
    description "记录对退回所做的处理：是否签发了替换订单、付款或账单账户信用"
  end

  postgres do
    table "order_return_item_responses"
    repo UniboExPoc.Repo
  end

  graphql do
    type :ofbiz_order_return_item_response

    queries do
      get :get_ofbiz_order_return_item_response, :read
      list :list_ofbiz_order_return_item_responses, :read
    end

    mutations do
      create :create_ofbiz_order_return_item_response, :create
      update :update_ofbiz_order_return_item_response, :update
      destroy :delete_ofbiz_order_return_item_response, :destroy
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
    belongs_to :order_payment_preference, UniboExPoc.Ofbiz.Order.OrderPaymentPreference do
      public? true
      attribute_type :string
    end
    belongs_to :replacement_order_header, UniboExPoc.Ofbiz.Order.OrderHeader do
      public? true
      source_attribute :replacement_order_id
      attribute_type :string
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  archive do
  end

end
