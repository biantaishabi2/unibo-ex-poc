# Workflow: refund_order_lifecycle — 退票单生命周期：pending → approved → refunded，pending → rejected
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> approve
#   create --> reject
#   approve --> refund
#   reject --> [*] : rejected
#   refund --> [*] : refunded
# ```
defmodule UniboExPoc.Travel.TravelRefundOrder do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Travel,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource],
    notifiers: [UniboExPoc.Travel.TravelRefundOrder.Notifier]

  resource do
    description "退票/退订单，记录针对已有 TravelOrder 的退票请求、手续费与退款状态"
  end

  postgres do
    table "travel_refund_orders"
    repo UniboExPoc.Repo
    identity_index_names unique_order_status: "idx_travel_refund_orders_unique_order_status"
  end

  graphql do
    type :travel_travel_refund_order

    queries do
      get :get_travel_travel_refund_order, :read
      list :list_travel_travel_refund_orders, :read
    end

    mutations do
      create :create_travel_travel_refund_order, :create
      update :approve_travel_travel_refund_order, :approve
      update :reject_travel_travel_refund_order, :reject
      update :refund_travel_travel_refund_order, :refund
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :refund_reason, :string do
      public? true
      description "退票原因"
    end
    attribute :refund_fee, :string do
      public? true
      description "退票手续费"
    end
    attribute :refund_amount, :string do
      public? true
      description "实退金额"
    end
    attribute :status, :atom do
      constraints one_of: [:pending, :approved, :refunded, :rejected]
      default :pending
      public? true
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :original_order, UniboExPoc.Travel.TravelOrder do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read]
    create :create do
      description "Create Travel Refund Order via Create. doc_url: graphql://contract/travel/create_travel_travel_refund_order"
      primary? true
      accept [:original_order_id, :refund_reason, :refund_fee, :refund_amount]
      argument :original_order_id, :uuid, allow_nil?: false
      change manage_relationship(:original_order_id, :original_order, type: :append, on_lookup: :relate)
      validate present(:original_order_id)
    end
    update :approve do
      description "Update Travel Refund Order via Approve. doc_url: graphql://contract/travel/approve_travel_travel_refund_order"
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
      # message: "只有 pending 退票单可以审批或拒绝"
      change set_attribute(:status, :approved)
      require_atomic? false
    end
    update :reject do
      description "Update Travel Refund Order via Reject. doc_url: graphql://contract/travel/reject_travel_travel_refund_order"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :pending do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :pending}))
        end
      end
      # message: "只有 pending 退票单可以审批或拒绝"
      change set_attribute(:status, :rejected)
      require_atomic? false
    end
    update :refund do
      description "Update Travel Refund Order via Refund. doc_url: graphql://contract/travel/refund_travel_travel_refund_order"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :approved do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :approved}))
        end
      end
      # message: "只有 approved 退票单可以执行退款"
      change set_attribute(:status, :refunded)
      require_atomic? false
    end
  end

  identities do
    identity :unique_order_status, [:original_order_id, :status]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
