# Workflow: payment_creation — POS 支付创建流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
# ```
defmodule UniboV4.POS.PosPayment do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.POS,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "POS 付款，记录单笔支付及外部交易追踪信息"
  end

  postgres do
    table "pos_payments"
    repo UniboV4.Repo
  end

  graphql do
    type :pos_pos_payment

    queries do
      get :get_pos_pos_payment, :read
      list :list_pos_pos_payments, :read
    end

    mutations do
      create :create_pos_pos_payment, :create
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :amount, :decimal do
      allow_nil? false
      public? true
      description "支付金额（正常支付 > 0，找零 < 0）"
    end
    attribute :is_change, :boolean do
      default false
      public? true
      description "是否找零记录"
    end
    attribute :reference_number, :string do
      public? true
      description "支付流水号"
    end
    attribute :card_type, :string do
      public? true
      description "卡类型"
    end
    attribute :cardholder_name, :string do
      public? true
      description "持卡人"
    end
    attribute :transaction_id, :string do
      public? true
      description "外部交易ID"
    end
    attribute :payment_status, :string do
      public? true
      description "外部支付状态"
    end
    attribute :ticket, :string do
      public? true
      description "支付凭条"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :order, UniboV4.POS.PosOrder do
      public? true
      allow_nil? false
    end
    belongs_to :payment_method, UniboV4.POS.PosPaymentMethod do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read, :update]
    create :create do
      primary? true
      accept [:payment_method_id, :amount, :is_change, :reference_number, :card_type, :cardholder_name, :transaction_id, :payment_status, :ticket]
      argument :order_id, :uuid, allow_nil?: false
      change manage_relationship(:order_id, :order, type: :append, on_lookup: :relate)
      argument :payment_method_id, :uuid, allow_nil?: false
      change manage_relationship(:payment_method_id, :payment_method, type: :append, on_lookup: :relate)
      change UniboV4.POS.Changes.PosPayment.CreateCall1
      change set_attribute(:id, expr(id))
    end
  end

  validations do
    # validation: valid_amount_sign — 正常支付金额必须大于零；找零金额必须小于零且标记 is_change
    # validation: session_association
  end

end
