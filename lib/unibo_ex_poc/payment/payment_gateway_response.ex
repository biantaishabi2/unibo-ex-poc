# Workflow: gateway_response_record_flow — 网关响应记录流程（仅创建和查询，审计记录不可变）
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   update --> [*]
# ```
defmodule UniboV4.Payment.PaymentGatewayResponse do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Payment,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "支付网关每次处理（授权/捕获/退款/作废）的原始响应，是审计追踪和对账的关键数据"
  end

  postgres do
    table "payment_gateway_responses"
    repo UniboV4.Repo
  end

  graphql do
    type :payment_payment_gateway_response

    queries do
      get :get_payment_payment_gateway_response, :read
      list :list_payment_payment_gateway_responses, :read
    end

    mutations do
      create :create_payment_payment_gateway_response, :create
      update :update_payment_payment_gateway_response, :update
      destroy :delete_payment_payment_gateway_response, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :payment_service_type_enum_id, :atom do
      allow_nil? false
      constraints one_of: [:auth, :capture, :release, :refund, :void]
      public? true
      description "服务类型（授权/捕获/释放/退款/作废）"
    end
    attribute :order_payment_preference_id, :string do
      public? true
      description "关联订单支付偏好"
    end
    attribute :payment_method_type_id, :string do
      public? true
      description "支付方式类型"
    end
    attribute :trans_code_enum_id, :string do
      public? true
      description "交易代码枚举"
    end
    attribute :amount, :decimal do
      allow_nil? false
      public? true
      description "交易金额"
    end
    attribute :currency_uom_id, :string do
      allow_nil? false
      public? true
      description "货币单位"
    end
    attribute :reference_num, :string do
      public? true
      description "网关返回的主参考号"
    end
    attribute :alt_reference, :string do
      public? true
      description "备用参考号"
    end
    attribute :sub_reference, :string do
      public? true
      description "子参考号"
    end
    attribute :gateway_code, :string do
      public? true
      description "网关响应码（如\"00\"表示成功）"
    end
    attribute :gateway_flag, :string do
      public? true
      description "网关标志位"
    end
    attribute :gateway_avs_result, :string do
      public? true
      description "AVS（地址验证）结果"
    end
    attribute :gateway_cv_result, :string do
      public? true
      description "CVV 验证结果"
    end
    attribute :gateway_score_result, :string do
      public? true
      description "风控评分结果"
    end
    attribute :gateway_message, :string do
      public? true
      description "网关返回的消息文本"
    end
    attribute :transaction_date, :utc_datetime do
      allow_nil? false
      public? true
      description "网关交易时间"
    end
    attribute :result_declined, :boolean do
      default false
      public? true
      description "是否被拒绝"
    end
    attribute :result_nsf, :boolean do
      default false
      public? true
      description "是否余额不足（NSF）"
    end
    attribute :result_bad_expire, :boolean do
      default false
      public? true
      description "是否卡片过期"
    end
    attribute :result_bad_card_number, :boolean do
      default false
      public? true
      description "是否卡号无效"
    end
    create_timestamp :inserted_at
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :payment_method, UniboV4.Payment.PaymentMethod do
      public? true
    end
    belongs_to :provider, UniboV4.Payment.PaymentProvider do
      public? true
      source_attribute :payment_provider_id
    end
    has_many :payments, UniboV4.Payment.Payment do
      public? true
      destination_attribute :payment_gateway_response_id
    end
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:payment_service_type_enum_id, :order_payment_preference_id, :payment_method_type_id, :payment_method_id, :payment_provider_id, :trans_code_enum_id, :amount, :currency_uom_id, :reference_num, :alt_reference, :sub_reference, :gateway_code, :gateway_flag, :gateway_avs_result, :gateway_cv_result, :gateway_score_result, :gateway_message, :transaction_date, :result_declined, :result_nsf, :result_bad_expire, :result_bad_card_number]
      validate present(:payment_service_type_enum_id)
      validate present(:amount)
      validate present(:currency_uom_id)
      validate present(:transaction_date)
      change set_attribute(:id, expr(id))
    end
    update :update do
      description "仅允许更新网关消息补充字段，响应记录原则上不可变"
      primary? true
      accept [:gateway_message, :gateway_code, :gateway_flag]
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
    archive_related [:payments]
  end

end
