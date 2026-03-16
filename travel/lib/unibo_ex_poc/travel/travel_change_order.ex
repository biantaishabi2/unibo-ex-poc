# Workflow: change_order_lifecycle — 改签单生命周期：pending → approved → completed，pending → rejected
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> approve
#   create --> reject
#   approve --> complete
#   reject --> [*] : rejected
#   complete --> [*] : completed
# ```
defmodule UniboExPoc.Travel.TravelChangeOrder do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Travel,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource],
    notifiers: [UniboExPoc.Travel.TravelChangeOrder.Notifier]

  resource do
    description "改签单，记录针对已有 TravelOrder 的改签请求、差价与审批状态"
  end

  postgres do
    table "travel_change_orders"
    repo UniboExPoc.Repo
    identity_index_names unique_order_status: "idx_travel_change_orders_unique_order_status"
  end

  graphql do
    type :travel_travel_change_order

    queries do
      get :get_travel_travel_change_order, :read
      list :list_travel_travel_change_orders, :read
    end

    mutations do
      create :create_travel_travel_change_order, :create
      update :approve_travel_travel_change_order, :approve
      update :reject_travel_travel_change_order, :reject
      update :complete_travel_travel_change_order, :complete
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :change_reason, :string do
      public? true
      description "改签原因"
    end
    attribute :price_difference, :string do
      public? true
      description "差价"
    end
    attribute :change_fee, :string do
      public? true
      description "改签手续费"
    end
    attribute :new_offer_id, :string do
      public? true
      description "新报价ID（可能是 FlightOffer/TrainOffer/HotelOffer，不做外键）"
    end
    attribute :status, :atom do
      constraints one_of: [:pending, :approved, :completed, :rejected]
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
      description "Create Travel Change Order via Create. doc_url: graphql://contract/travel/create_travel_travel_change_order"
      primary? true
      accept [:original_order_id, :change_reason, :price_difference, :change_fee, :new_offer_id]
      argument :original_order_id, :uuid, allow_nil?: false
      change manage_relationship(:original_order_id, :original_order, type: :append, on_lookup: :relate)
      validate present(:original_order_id)
    end
    update :approve do
      description "Update Travel Change Order via Approve. doc_url: graphql://contract/travel/approve_travel_travel_change_order"
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
      # message: "只有 pending 改签单可以审批或拒绝"
      change set_attribute(:status, :approved)
      require_atomic? false
    end
    update :reject do
      description "Update Travel Change Order via Reject. doc_url: graphql://contract/travel/reject_travel_travel_change_order"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :pending do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :pending}))
        end
      end
      # message: "只有 pending 改签单可以审批或拒绝"
      change set_attribute(:status, :rejected)
      require_atomic? false
    end
    update :complete do
      description "Update Travel Change Order via Complete. doc_url: graphql://contract/travel/complete_travel_travel_change_order"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :approved do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :approved}))
        end
      end
      # message: "只有 approved 改签单可以完成"
      change set_attribute(:status, :completed)
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
