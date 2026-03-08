# Workflow: travel_order_lifecycle — 统一酒旅订单生命周期，覆盖 train 候补与改签分支；退款由 Payment 域处理
# ```mermaid
# stateDiagram-v2
#   [*] --> create_order
#   create_order --> update
#   create_order --> confirm_quote
#   create_order --> destroy
#   update --> confirm_quote
#   update --> destroy
#   confirm_quote --> submit_order
#   confirm_quote --> submit_waitlist
#   submit_order --> mark_payment_succeeded
#   submit_order --> mark_order_failed
#   submit_waitlist --> mark_payment_succeeded
#   submit_waitlist --> mark_order_failed
#   mark_payment_succeeded --> mark_booked
#   mark_payment_succeeded --> fulfill_waitlist
#   mark_payment_succeeded --> cancel_waitlist
#   mark_booked --> mark_completed
#   mark_booked --> request_cancel
#   mark_booked --> request_change
#   fulfill_waitlist --> mark_completed
#   fulfill_waitlist --> request_cancel
#   fulfill_waitlist --> request_change
#   cancel_waitlist --> [*] : waitlist_cancelled
#   request_cancel --> approve_cancel
#   approve_cancel --> [*] : cancelled
#   request_change --> confirm_change
#   confirm_change --> mark_completed
#   mark_completed --> [*]
#   mark_order_failed --> [*] : failed
#   destroy --> [*]
# ```
defmodule UniboExPoc.Travel.TravelOrder do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Travel,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource],
    notifiers: [UniboExPoc.Travel.TravelOrder.Notifier]

  resource do
    description "统一酒旅订单，承接 hotel、flight、vacation、train 四类商品的下单和状态流转；通过跨域引用关联 Sales::Customer 和 Payment::Payment"
  end

  postgres do
    table "travel_orders"
    repo UniboExPoc.Repo
  end

  multitenancy do
    strategy :attribute
    attribute :tenant_id
  end

  graphql do
    type :travel_travel_order

    queries do
      get :get_travel_travel_order, :read
      list :list_travel_travel_orders, :read
    end

    mutations do
      create :create_create_order_travel_travel_order, :create_order
      update :update_travel_travel_order, :update
      update :confirm_quote_travel_travel_order, :confirm_quote
      update :submit_order_travel_travel_order, :submit_order
      update :submit_waitlist_travel_travel_order, :submit_waitlist
      update :mark_payment_succeeded_travel_travel_order, :mark_payment_succeeded
      update :mark_booked_travel_travel_order, :mark_booked
      update :fulfill_waitlist_travel_travel_order, :fulfill_waitlist
      update :mark_completed_travel_travel_order, :mark_completed
      update :request_cancel_travel_travel_order, :request_cancel
      update :cancel_waitlist_travel_travel_order, :cancel_waitlist
      update :approve_cancel_travel_travel_order, :approve_cancel
      update :request_change_travel_travel_order, :request_change
      update :confirm_change_travel_travel_order, :confirm_change
      update :mark_order_failed_travel_travel_order, :mark_order_failed
      destroy :delete_travel_travel_order, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :tenant_id, :uuid do
      allow_nil? false
      public? true
    end
    attribute :host_shop_id, :uuid do
      public? true
      description "宿主商城 ID，用于 sidecar 对接上下文"
    end
    attribute :order_no, :string do
      allow_nil? false
      public? true
      description "订单号"
    end
    attribute :product_type, :atom do
      constraints one_of: [:hotel, :flight, :vacation, :train]
      default :hotel
      public? true
      description "商品类型"
    end
    attribute :booking_mode, :atom do
      constraints one_of: [:standard, :waitlist]
      default :standard
      public? true
      description "train 订单预订模式"
    end
    attribute :contact_name, :string do
      allow_nil? false
      public? true
    end
    attribute :contact_phone, :string do
      allow_nil? false
      public? true
    end
    attribute :traveler_count, :integer do
      default 1
      public? true
      description "出行人数量"
    end
    attribute :total_amount, :decimal do
      allow_nil? false
      public? true
      description "订单总金额"
    end
    attribute :points_to_use, :integer do
      default 0
      public? true
      description "计划使用的积分数量"
    end
    attribute :points_deduction_amount, :decimal do
      default 0
      public? true
      description "积分抵现金额"
    end
    attribute :currency, :string do
      default "CNY"
      public? true
    end
    attribute :status, :atom do
      constraints one_of: [:draft, :quoted, :submitted, :booking_pending, :booked, :cancel_pending, :cancelled, :completed, :failed]
      default :draft
      public? true
    end
    attribute :change_status, :atom do
      constraints one_of: [:none, :pending, :changed, :failed]
      default :none
      public? true
    end
    attribute :waitlist_status, :atom do
      constraints one_of: [:none, :pending, :fulfilled, :cancelled, :failed]
      default :none
      public? true
    end
    attribute :original_order_ref, :string do
      public? true
      description "改签链路引用的原订单号或原票号"
    end
    attribute :ticket_passenger_infos, :map do
      public? true
      description "乘车人信息快照"
    end
    attribute :seat_selection_snapshot, :map do
      public? true
      description "选座与席别偏好快照"
    end
    attribute :supplier_order_ref, :string do
      public? true
      description "供应商订单号"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  calculations do
    calculate :payable_amount, :decimal, expr((total_amount - points_deduction_amount))
  end

  relationships do
    belongs_to :hotel_offer, UniboExPoc.Travel.HotelOffer do
      public? true
    end
    belongs_to :flight_offer, UniboExPoc.Travel.FlightOffer do
      public? true
    end
    belongs_to :vacation_offer, UniboExPoc.Travel.VacationOffer do
      public? true
    end
    belongs_to :train_offer, UniboExPoc.Travel.TrainOffer do
      public? true
    end
    has_many :fulfillments, UniboExPoc.Travel.TravelFulfillment do
      public? true
      destination_attribute :travel_order_id
    end
    belongs_to :customer, UniboExPoc.Sales.Customer do
      public? true
    end
    belongs_to :payment, UniboExPoc.Payment.Payment do
      public? true
    end
  end

  actions do
    defaults [:read, :destroy]
    create :create_order do
      primary? true
      accept [:tenant_id, :host_shop_id, :hotel_offer_id, :flight_offer_id, :vacation_offer_id, :train_offer_id, :order_no, :product_type, :customer_id, :contact_name, :contact_phone, :traveler_count, :total_amount, :points_to_use, :points_deduction_amount, :currency, :ticket_passenger_infos, :seat_selection_snapshot]
      validate present(:tenant_id)
      validate present(:order_no)
      validate present(:customer_id)
      validate present(:contact_name)
      validate present(:contact_phone)
      validate present([:hotel_offer_id, :flight_offer_id, :vacation_offer_id, :train_offer_id], exactly: 1)
      # message: "hotel_offer_id、flight_offer_id、vacation_offer_id、train_offer_id 必须四选一"
      validate present(:hotel_offer_id)
      # message: "hotel 订单必须绑定 hotel_offer_id"
      validate present(:flight_offer_id)
      # message: "flight 订单必须绑定 flight_offer_id"
      validate present(:vacation_offer_id)
      # message: "vacation 订单必须绑定 vacation_offer_id"
      validate present(:train_offer_id)
      # message: "train 订单必须绑定 train_offer_id"
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
      change UniboExPoc.Travel.Integrations.TravelOrder.CreateOrderShopCallerContextResolveBridge
    end
    update :update do
      primary? true
      accept [:contact_name, :contact_phone, :traveler_count, :ticket_passenger_infos, :seat_selection_snapshot]
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
    update :confirm_quote do
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :draft do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :draft}))
        end
      end
      # message: "只有 draft 订单可以 confirm_quote"
      change set_attribute(:status, :quoted)
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
      change UniboExPoc.Travel.Integrations.TravelOrder.ConfirmQuoteShopEligibilityQuoteBridge
      require_atomic? false
    end
    update :submit_order do
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :quoted do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :quoted}))
        end
      end
      # message: "只有 quoted 订单可以提交普通购票或候补"
      change set_attribute(:status, :submitted)
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
      change UniboExPoc.Travel.Integrations.TravelOrder.SubmitOrderPaymentCaptureBridge
      require_atomic? false
    end
    update :submit_waitlist do
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :quoted do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :quoted}))
        end
      end
      # message: "只有 quoted 订单可以提交普通购票或候补"
      change set_attribute(:status, :submitted)
      change set_attribute(:booking_mode, :waitlist)
      change set_attribute(:waitlist_status, :pending)
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
      change UniboExPoc.Travel.Integrations.TravelOrder.SubmitWaitlistPaymentCaptureBridge
      require_atomic? false
    end
    update :mark_payment_succeeded do
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :submitted do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :submitted}))
        end
      end
      # message: "只有 submitted 订单可以进入支付成功或失败结果"
      change set_attribute(:status, :booking_pending)
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
      change UniboExPoc.Travel.Integrations.TravelOrder.MarkPaymentSucceededSupplierBookingSubmitBridge
      require_atomic? false
    end
    update :mark_booked do
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :booking_pending do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :booking_pending}))
        end
      end
      # message: "只有 booking_pending 订单可以完成出票、兑现候补或取消候补"
      change set_attribute(:status, :booked)
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
    update :fulfill_waitlist do
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :booking_pending do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :booking_pending}))
        end
      end
      # message: "只有 booking_pending 订单可以完成出票、兑现候补或取消候补"
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :waitlist_status)
        if current == :pending do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :waitlist_status, message: "must equal %{value}", vars: %{value: :pending}))
        end
      end
      # message: "只有 waitlist_pending 的订单可以兑现或取消候补"
      change set_attribute(:status, :booked)
      change set_attribute(:waitlist_status, :fulfilled)
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
    update :mark_completed do
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :booked do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :booked}))
        end
      end
      # message: "只有 booked 订单可以完成、取消或改签"
      change set_attribute(:status, :completed)
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
    update :request_cancel do
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :booked do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :booked}))
        end
      end
      # message: "只有 booked 订单可以完成、取消或改签"
      change set_attribute(:status, :cancel_pending)
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
    update :cancel_waitlist do
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :booking_pending do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :booking_pending}))
        end
      end
      # message: "只有 booking_pending 订单可以完成出票、兑现候补或取消候补"
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :waitlist_status)
        if current == :pending do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :waitlist_status, message: "must equal %{value}", vars: %{value: :pending}))
        end
      end
      # message: "只有 waitlist_pending 的订单可以兑现或取消候补"
      change set_attribute(:status, :cancelled)
      change set_attribute(:waitlist_status, :cancelled)
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
    update :approve_cancel do
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :cancel_pending do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :cancel_pending}))
        end
      end
      # message: "只有 cancel_pending 订单可以 approve_cancel"
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
    update :request_change do
      accept [:original_order_ref]
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :booked do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :booked}))
        end
      end
      # message: "只有 booked 订单可以完成、取消或改签"
      # skipped: validate present :original_order_ref (incompatible with bulk update atomic path)
      change set_attribute(:change_status, :pending)
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
    update :confirm_change do
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :change_status)
        if current == :pending do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :change_status, message: "must equal %{value}", vars: %{value: :pending}))
        end
      end
      # message: "只有 change_pending 的订单可以 confirm_change"
      # skipped: validate present :original_order_ref (incompatible with bulk update atomic path)
      change set_attribute(:change_status, :changed)
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
    update :mark_order_failed do
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :submitted do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :submitted}))
        end
      end
      # message: "只有 submitted 订单可以进入支付成功或失败结果"
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
  end

  validations do
    validate compare(:traveler_count, greater_than_or_equal_to: 1)
    validate compare(:total_amount, greater_than_or_equal_to: 0)
    validate compare(:points_to_use, greater_than_or_equal_to: 0)
    validate compare(:points_deduction_amount, greater_than_or_equal_to: 0)
  end

  identities do
    identity :unique_order_no, [:order_no]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
    archive_related [:fulfillments]
  end

end
