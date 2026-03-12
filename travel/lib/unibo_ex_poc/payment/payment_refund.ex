# Workflow: refund_lifecycle — 退款生命周期流程（pending → approved → processed / rejected）
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> approve
#   create --> reject
#   approve --> process
#   process --> [*] : processed
#   reject --> [*] : rejected
# ```
defmodule UniboExPoc.Payment.PaymentRefund do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Payment,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource],
    notifiers: [UniboExPoc.Payment.PaymentRefund.Notifier]

  resource do
    description "支付退款记录，记录每笔退款的金额、原因、状态和处理时间"
  end

  postgres do
    table "payment_refunds"
    repo UniboExPoc.Repo
  end

  graphql do
    type :payment_payment_refund

    queries do
      get :get_payment_payment_refund, :read
      list :list_payment_payment_refunds, :read
    end

    mutations do
      create :create_payment_payment_refund, :create
      update :approve_payment_payment_refund, :approve
      update :process_payment_payment_refund, :process
      update :reject_payment_payment_refund, :reject
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :amount, :decimal do
      allow_nil? false
      public? true
      description "退款金额"
    end
    attribute :reason, :string do
      public? true
      description "退款原因"
    end
    attribute :status, :atom do
      allow_nil? false
      constraints one_of: [:pending, :approved, :processed, :rejected]
      default :pending
      public? true
      description "退款状态"
    end
    attribute :refund_method, :string do
      public? true
      description "退款方式（原路退回、余额退款等）"
    end
    attribute :processed_at, :utc_datetime do
      public? true
      description "退款处理完成时间"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :payment, UniboExPoc.Payment.Payment do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read]
    create :create do
      description "Create Payment Refund via Create. doc_url: graphql://contract/payment/create_payment_payment_refund"
      primary? true
      accept [:payment_id, :amount, :reason, :refund_method]
      argument :payment_id, :uuid, allow_nil?: false
      change manage_relationship(:payment_id, :payment, type: :append, on_lookup: :relate)
      validate present(:payment_id)
      validate present(:amount)
    end
    update :approve do
      description "审批退款，状态从 pending 变为 approved

审批退款，状态从 pending 变为 approved. doc_url: graphql://contract/payment/approve_payment_payment_refund"
      primary? true
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :pending do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :pending}))
        end
      end
      # message: "只有待处理状态可以审批"
      change set_attribute(:status, :approved)
      require_atomic? false
    end
    update :process do
      description "处理退款，状态从 approved 变为 processed

处理退款，状态从 approved 变为 processed. doc_url: graphql://contract/payment/process_payment_payment_refund"
      accept [:processed_at]
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :approved do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :approved}))
        end
      end
      # message: "只有已审批状态可以处理"
      change set_attribute(:status, :processed)
      require_atomic? false
    end
    update :reject do
      description "拒绝退款，状态从 pending 变为 rejected

拒绝退款，状态从 pending 变为 rejected. doc_url: graphql://contract/payment/reject_payment_payment_refund"
      accept [:reason]
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :pending do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :pending}))
        end
      end
      # message: "只有待处理状态可以拒绝"
      change set_attribute(:status, :rejected)
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

end
