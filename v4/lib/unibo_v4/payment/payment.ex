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
defmodule UniboV4.Payment.Payment do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Payment,
    data_layer: AshPostgres.DataLayer,
    notifiers: [UniboV4.Payment.Payment.Notifier]

  postgres do
    table "payment_payments"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :payment_method_type_id, :string, public?: true
    attribute :payment_preference_id, :string, public?: true
    attribute :status, :atom do
      allow_nil? false
      constraints one_of: [:draft, :pending, :authorized, :captured, :refunded, :cancelled, :failed]
      default :draft
      public? true
    end
    attribute :effective_date, :utc_datetime do
      allow_nil? false
      public? true
    end
    attribute :payment_ref_num, :string, public?: true
    attribute :amount, :decimal do
      allow_nil? false
      public? true
    end
    attribute :currency_uom_id, :string do
      allow_nil? false
      public? true
    end
    attribute :actual_currency_amount, :decimal, public?: true
    attribute :actual_currency_uom_id, :string, public?: true
    attribute :comments, :string, public?: true
    attribute :fin_account_trans_id, :string, public?: true
    attribute :override_gl_account_id, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  calculations do
    # TODO: 不支持的 calculation 表达式 :refunded_amount
    # TODO: 不支持的 calculation 表达式 :remaining_amount
  end

  relationships do
    belongs_to :payment_type, UniboV4.Payment.PaymentType do
      public? true
    end
    belongs_to :payment_method, UniboV4.Payment.PaymentMethod do
      public? true
    end
    belongs_to :gateway_response, UniboV4.Payment.PaymentGatewayResponse do
      public? true
      source_attribute :payment_gateway_response_id
    end
    belongs_to :from_party, UniboV4.Payment.Party do
      public? true
      source_attribute :party_id_from
    end
    belongs_to :to_party, UniboV4.Payment.Party do
      public? true
      source_attribute :party_id_to
    end
    has_many :applications, UniboV4.Payment.PaymentApplication do
      public? true
      destination_attribute :payment_id
    end
    has_many :refunds, UniboV4.Payment.PaymentRefund do
      public? true
      destination_attribute :payment_id
    end
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:payment_method_type_id, :payment_preference_id, :status, :effective_date, :payment_ref_num, :amount, :currency_uom_id, :actual_currency_amount, :actual_currency_uom_id, :comments, :fin_account_trans_id, :override_gl_account_id]
      validate present(:payment_type_id)
      validate present(:party_id_from)
      validate present(:party_id_to)
      validate present(:amount)
      validate present(:currency_uom_id)
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
    end
    update :update do
      primary? true
      accept [:payment_ref_num, :comments, :override_gl_account_id]
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
      require_atomic? false
    end
    update :submit do
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
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
      require_atomic? false
    end
    update :authorize do
      accept [:payment_ref_num]
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
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
      require_atomic? false
    end
    update :capture do
      accept [:payment_ref_num]
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
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
      require_atomic? false
    end
    update :mark_failed do
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
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
      require_atomic? false
    end
    update :cancel do
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
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
      require_atomic? false
    end
    update :refund do
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
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
      require_atomic? false
    end
  end

  validations do
    validate compare(:amount, greater_than: 0)
  end

end
