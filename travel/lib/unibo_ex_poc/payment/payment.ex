# Workflow: payment_lifecycle — 支付生命周期流程（draft → pending → authorized → captured → refunded/cancelled/failed）
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> submit
#   create --> cancel
#   create --> destroy
#   update --> submit
#   update --> cancel
#   update --> destroy
#   submit --> authorize
#   submit --> mark_failed
#   submit --> cancel
#   authorize --> capture
#   authorize --> mark_failed
#   authorize --> cancel
#   capture --> refund
#   refund --> [*] : refunded
#   mark_failed --> [*] : failed
#   cancel --> [*] : cancelled
#   destroy --> [*]
# ```
defmodule UniboExPoc.Payment.Payment do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Payment,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource],
    authorizers: [Ash.Policy.Authorizer],
    notifiers: [Ash.Notifier.PubSub]

  resource do
    description "核心支付流水实体，记录每笔实际支付的完整信息，支持状态流转（draft→pending→authorized→captured→refunded/cancelled/failed）"
  end

  postgres do
    table "payment_payments"
    repo UniboExPoc.Repo
  end

  graphql do
    type :payment_payment

    queries do
      get :get_payment_payment, :read
      list :list_payment_payments, :read
    end

    mutations do
      create :create_payment_payment, :create
      update :update_payment_payment, :update
      update :submit_payment_payment, :submit
      update :authorize_payment_payment, :authorize
      update :capture_payment_payment, :capture
      update :mark_failed_payment_payment, :mark_failed
      update :cancel_payment_payment, :cancel
      update :refund_payment_payment, :refund
      destroy :delete_payment_payment, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :payment_method_type_id, :string do
      public? true
      description "支付方式类型（冗余存储，方便查询）"
    end
    attribute :payment_preference_id, :string do
      public? true
      description "关联的订单支付偏好 ID"
    end
    attribute :status, :atom do
      allow_nil? false
      constraints one_of: [:draft, :pending, :authorized, :captured, :refunded, :cancelled, :failed]
      default :draft
      public? true
      description "支付状态（draft→pending→authorized→captured；可流转到 refunded/cancelled/failed）"
    end
    attribute :effective_date, :utc_datetime do
      allow_nil? false
      public? true
      description "支付生效日期"
    end
    attribute :payment_ref_num, :string do
      public? true
      description "支付参考编号（第三方流水号）"
    end
    attribute :amount, :decimal do
      allow_nil? false
      public? true
      description "支付金额"
    end
    attribute :currency_uom_id, :string do
      allow_nil? false
      public? true
      description "货币单位（USD、CNY 等）"
    end
    attribute :actual_currency_amount, :decimal do
      public? true
      description "实际货币金额（汇率转换后）"
    end
    attribute :actual_currency_uom_id, :string do
      public? true
      description "实际货币单位"
    end
    attribute :comments, :string do
      public? true
      description "备注"
    end
    attribute :fin_account_trans_id, :string do
      public? true
      description "关联金融账户交易 ID"
    end
    attribute :override_gl_account_id, :string do
      public? true
      description "覆盖总账科目 ID"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  calculations do
    calculate :refunded_amount, :decimal, {UniboExPoc.Payment.Calculations.Payment.RefundedAmount, []}
    calculate :remaining_amount, :decimal, expr((amount - refunded_amount))
  end

  relationships do
    belongs_to :payment_type_ref, UniboExPoc.Payment.PaymentType do
      public? true
      source_attribute :payment_type_id
    end
    belongs_to :payment_method_ref, UniboExPoc.Payment.PaymentMethod do
      public? true
      source_attribute :payment_method_id
    end
    belongs_to :gateway_response, UniboExPoc.Payment.PaymentGatewayResponse do
      public? true
      source_attribute :payment_gateway_response_id
    end
    belongs_to :from_party, UniboExPoc.Payment.Party do
      public? true
      source_attribute :party_id_from
    end
    belongs_to :to_party, UniboExPoc.Payment.Party do
      public? true
      source_attribute :party_id_to
    end
    belongs_to :company_party, UniboExPoc.Payment.Party do
      public? true
      source_attribute :party_id_to
      define_attribute? false
    end
    has_many :applications, UniboExPoc.Payment.PaymentApplication do
      public? true
      destination_attribute :payment_id
    end
    has_many :refunds, UniboExPoc.Payment.PaymentRefund do
      public? true
      destination_attribute :payment_id
    end
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      description "Create Payment via Create. doc_url: graphql://contract/payment/create_payment_payment"
      primary? true
      accept [:payment_type_id, :payment_method_type_id, :payment_method_id, :payment_preference_id, :party_id_from, :party_id_to, :status, :effective_date, :payment_ref_num, :amount, :currency_uom_id, :actual_currency_amount, :actual_currency_uom_id, :comments, :fin_account_trans_id, :override_gl_account_id]
      validate present(:payment_type_id)
      validate present(:party_id_from)
      validate present(:party_id_to)
      validate present(:amount)
      validate present(:currency_uom_id)
    end
    update :update do
      description "Update Payment via Update. doc_url: graphql://contract/payment/update_payment_payment"
      primary? true
      accept [:payment_ref_num, :comments, :override_gl_account_id]
      require_atomic? false
    end
    update :submit do
      description "提交支付，状态从 draft 变为 pending

提交支付，状态从 draft 变为 pending. doc_url: graphql://contract/payment/submit_payment_payment"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :draft do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :draft}))
        end
      end
      # message: "只有草稿状态可以提交"
      change set_attribute(:status, :pending)
      require_atomic? false
    end
    update :authorize do
      description "授权支付，状态从 pending 变为 authorized

授权支付，状态从 pending 变为 authorized. doc_url: graphql://contract/payment/authorize_payment_payment"
      accept [:payment_ref_num, :payment_gateway_response_id]
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :pending do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :pending}))
        end
      end
      # message: "只有待处理状态可以授权"
      change set_attribute(:status, :authorized)
      require_atomic? false
    end
    update :capture do
      description "捕获/扣款，状态从 authorized 变为 captured

捕获/扣款，状态从 authorized 变为 captured. doc_url: graphql://contract/payment/capture_payment_payment"
      accept [:payment_ref_num, :payment_gateway_response_id]
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :authorized do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :authorized}))
        end
      end
      # message: "只有已授权状态可以捕获扣款"
      change set_attribute(:status, :captured)
      require_atomic? false
    end
    update :mark_failed do
      description "标记支付失败，状态变为 failed

标记支付失败，状态变为 failed. doc_url: graphql://contract/payment/mark_failed_payment_payment"
      accept [:comments]
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current in [:pending, :authorized] do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must be one of %{values}", vars: %{values: [:pending, :authorized]}))
        end
      end
      # message: "只有待处理或已授权状态可以标记失败"
      change set_attribute(:status, :failed)
      require_atomic? false
    end
    update :cancel do
      description "取消支付，状态变为 cancelled

取消支付，状态变为 cancelled. doc_url: graphql://contract/payment/cancel_payment_payment"
      accept [:comments]
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current in [:draft, :pending, :authorized] do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must be one of %{values}", vars: %{values: [:draft, :pending, :authorized]}))
        end
      end
      # message: "已捕获/已退款/已失败的支付不能取消"
      change set_attribute(:status, :cancelled)
      require_atomic? false
    end
    update :refund do
      description "标记已退款，状态从 captured 变为 refunded

标记已退款，状态从 captured 变为 refunded. doc_url: graphql://contract/payment/refund_payment_payment"
      accept [:comments]
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :captured do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :captured}))
        end
      end
      # message: "只有已捕获状态可以退款"
      change set_attribute(:status, :refunded)
      require_atomic? false
    end
  end

  validations do
    validate compare(:amount, greater_than: 0)
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
    archive_related [:applications, :refunds]
  end

  policies do
    policy action_type(:read) do
      authorize_if expr(^actor(:role) == :admin)
      authorize_if relates_to_actor_via(:company_party)
    end
    policy action_type(:update) do
      authorize_if expr(^actor(:role) == :admin)
      authorize_if relates_to_actor_via(:company_party)
    end
    policy action_type(:create) do
      forbid_unless relates_to_actor_via(:company_party)
      authorize_if expr(^actor(:role) in [:finance_clerk, :admin])
    end
    policy always() do
      authorize_if always()
    end
  end


  pub_sub do
    module UniboExPoc.PubSub
    prefix "payment"

    publish :authorize, ["payment.payment.authorized"]
    publish :capture, ["payment.payment.captured"]
    publish :refund, ["payment.payment.refunded"]
    publish :cancel, ["payment.payment.cancelled"]
    publish :mark_failed, ["payment.payment.failed"]
  end
end
