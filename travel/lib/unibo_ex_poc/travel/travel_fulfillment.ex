# Workflow: travel_fulfillment_lifecycle — 统一酒旅履约生命周期
# ```mermaid
# stateDiagram-v2
#   [*] --> create_fulfillment
#   create_fulfillment --> update
#   create_fulfillment --> confirm_booking
#   create_fulfillment --> fail_fulfillment
#   create_fulfillment --> cancel_fulfillment
#   create_fulfillment --> destroy
#   update --> confirm_booking
#   update --> fail_fulfillment
#   update --> cancel_fulfillment
#   update --> destroy
#   confirm_booking --> issue_voucher_or_ticket
#   issue_voucher_or_ticket --> mark_in_use
#   issue_voucher_or_ticket --> complete_fulfillment
#   mark_in_use --> complete_fulfillment
#   complete_fulfillment --> [*] : completed
#   cancel_fulfillment --> [*] : cancelled
#   fail_fulfillment --> [*] : failed
#   destroy --> [*]
# ```
defmodule UniboExPoc.Travel.TravelFulfillment do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Travel,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource],
    notifiers: [Ash.Notifier.PubSub]

  resource do
    description "统一酒旅履约聚合，承接预订确认、发券出票、候补兑现、乘车使用和失败结果；可选关联 Delivery::Shipment"
  end

  postgres do
    table "travel_fulfillments"
    repo UniboExPoc.Repo
  end

  multitenancy do
    strategy :attribute
    attribute :tenant_id
  end

  graphql do
    type :travel_travel_fulfillment

    queries do
      get :get_travel_travel_fulfillment, :read
      list :list_travel_travel_fulfillments, :read
    end

    mutations do
      create :create_create_fulfillment_travel_travel_fulfillment, :create_fulfillment
      update :update_travel_travel_fulfillment, :update
      update :confirm_booking_travel_travel_fulfillment, :confirm_booking
      update :issue_voucher_or_ticket_travel_travel_fulfillment, :issue_voucher_or_ticket
      update :mark_in_use_travel_travel_fulfillment, :mark_in_use
      update :complete_fulfillment_travel_travel_fulfillment, :complete_fulfillment
      update :cancel_fulfillment_travel_travel_fulfillment, :cancel_fulfillment
      update :fail_fulfillment_travel_travel_fulfillment, :fail_fulfillment
      destroy :delete_travel_travel_fulfillment, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :tenant_id, :uuid do
      allow_nil? false
      public? true
    end
    attribute :fulfillment_type, :atom do
      constraints one_of: [:reserve_room, :issue_ticket, :issue_voucher, :issue_train_ticket]
      default :reserve_room
      public? true
    end
    attribute :status, :atom do
      constraints one_of: [:pending, :confirmed, :issued, :in_use, :completed, :cancelled, :failed]
      default :pending
      public? true
    end
    attribute :supplier_booking_ref, :string do
      public? true
      description "供应商预订号"
    end
    attribute :voucher_or_ticket_ref, :string do
      public? true
      description "凭证号或票号"
    end
    attribute :ticket_refs, :map do
      public? true
      description "多张票号、座席和乘客映射结果"
    end
    attribute :waitlist_result, :atom do
      constraints one_of: [:none, :pending, :fulfilled, :cancelled, :failed]
      default :none
      public? true
      description "train 候补兑现结果"
    end
    attribute :change_result, :atom do
      constraints one_of: [:none, :pending, :changed, :failed]
      default :none
      public? true
      description "train 改签结果"
    end
    attribute :boarding_status, :atom do
      constraints one_of: [:not_started, :boarded, :completed]
      default :not_started
      public? true
      description "train 乘车状态"
    end
    attribute :confirmation_payload, :string do
      public? true
      description "确认结果快照"
    end
    attribute :failure_reason, :string do
      public? true
      description "失败原因"
    end
    attribute :used_at, :utc_datetime do
      public? true
      description "实际使用时间"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :order, UniboExPoc.Travel.TravelOrder do
      public? true
      allow_nil? false
      source_attribute :travel_order_id
    end
    belongs_to :shipment, UniboExPoc.Delivery.Shipment do
      public? true
    end
  end

  actions do
    defaults [:read, :destroy]
    create :create_fulfillment do
      description "Create Travel Fulfillment via Create Fulfillment. Headers: x-tenant-id. doc_url: graphql://contract/travel/create_create_fulfillment_travel_travel_fulfillment"
      primary? true
      accept [:tenant_id, :travel_order_id, :fulfillment_type, :supplier_booking_ref]
      argument :order_id, :uuid, allow_nil?: false
      change manage_relationship(:order_id, :order, type: :append, on_lookup: :relate)
      validate present(:tenant_id)
    end
    update :update do
      description "Update Travel Fulfillment via Update. Headers: x-tenant-id. doc_url: graphql://contract/travel/update_travel_travel_fulfillment"
      primary? true
      accept [:supplier_booking_ref, :voucher_or_ticket_ref, :ticket_refs, :confirmation_payload, :failure_reason]
      require_atomic? false
    end
    update :confirm_booking do
      description "Update Travel Fulfillment via Confirm Booking. Headers: x-tenant-id. doc_url: graphql://contract/travel/confirm_booking_travel_travel_fulfillment"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :pending do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :pending}))
        end
      end
      # message: "只有 pending 履约可以确认、失败或取消"
      change set_attribute(:status, :confirmed)
      change UniboExPoc.Travel.Integrations.TravelFulfillment.ConfirmBookingSupplierConfirmBookingBridge
      require_atomic? false
    end
    update :issue_voucher_or_ticket do
      description "Update Travel Fulfillment via Issue Voucher Or Ticket. Headers: x-tenant-id. doc_url: graphql://contract/travel/issue_voucher_or_ticket_travel_travel_fulfillment"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :confirmed do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :confirmed}))
        end
      end
      # message: "只有 confirmed 履约可以 issue_voucher_or_ticket"
      change set_attribute(:status, :issued)
      change UniboExPoc.Travel.Integrations.TravelFulfillment.IssueVoucherOrTicketSupplierIssueDocumentBridge
      require_atomic? false
    end
    update :mark_in_use do
      description "Update Travel Fulfillment via Mark In Use. Headers: x-tenant-id. doc_url: graphql://contract/travel/mark_in_use_travel_travel_fulfillment"
      accept [:used_at]
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :issued do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :issued}))
        end
      end
      # message: "只有 issued 履约可以 mark_in_use"
      change set_attribute(:status, :in_use)
      require_atomic? false
    end
    update :complete_fulfillment do
      description "Update Travel Fulfillment via Complete Fulfillment. Headers: x-tenant-id. doc_url: graphql://contract/travel/complete_fulfillment_travel_travel_fulfillment"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current in [:issued, :in_use] do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must be one of %{values}", vars: %{values: [:issued, :in_use]}))
        end
      end
      # message: "只有 issued 或 in_use 履约可以 complete_fulfillment"
      change set_attribute(:status, :completed)
      require_atomic? false
    end
    update :cancel_fulfillment do
      description "Update Travel Fulfillment via Cancel Fulfillment. Headers: x-tenant-id. doc_url: graphql://contract/travel/cancel_fulfillment_travel_travel_fulfillment"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :pending do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :pending}))
        end
      end
      # message: "只有 pending 履约可以确认、失败或取消"
      change set_attribute(:status, :cancelled)
      change UniboExPoc.Travel.Integrations.TravelFulfillment.CancelFulfillmentSupplierCancelBookingBridge
      require_atomic? false
    end
    update :fail_fulfillment do
      description "Update Travel Fulfillment via Fail Fulfillment. Headers: x-tenant-id. doc_url: graphql://contract/travel/fail_fulfillment_travel_travel_fulfillment"
      accept [:failure_reason]
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :pending do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :pending}))
        end
      end
      # message: "只有 pending 履约可以确认、失败或取消"
      change set_attribute(:status, :failed)
      require_atomic? false
    end
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    attributes_as_attributes [:tenant_id]
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
  end


  pub_sub do
    module UniboExPoc.PubSub
    prefix "travel_fulfillment"

    publish :confirm_booking, ["travel.fulfillment.confirmed"]
    publish :issue_voucher_or_ticket, ["travel.fulfillment.issued"]
    publish :complete_fulfillment, ["travel.fulfillment.completed"]
    publish :cancel_fulfillment, ["travel.fulfillment.cancelled"]
    publish :fail_fulfillment, ["travel.fulfillment.failed"]
  end
end
