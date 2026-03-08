# Workflow: flight_offer_lifecycle — 机票 offer 生命周期
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> activate
#   create --> destroy
#   update --> activate
#   update --> destroy
#   activate --> deactivate
#   activate --> expire
#   deactivate --> activate
#   expire --> [*] : expired
#   destroy --> [*]
# ```
defmodule UniboV4.Travel.FlightOffer do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Travel,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource],
    notifiers: [UniboV4.Travel.FlightOffer.Notifier]

  resource do
    description "机票可售 offer，承载航班、舱位、票规和库存快照"
  end

  postgres do
    table "travel_flight_offers"
    repo UniboV4.Repo
  end

  multitenancy do
    strategy :attribute
    attribute :tenant_id
  end

  graphql do
    type :travel_flight_offer

    queries do
      get :get_travel_flight_offer, :read
      list :list_travel_flight_offers, :read
    end

    mutations do
      create :create_travel_flight_offer, :create
      update :update_travel_flight_offer, :update
      update :activate_travel_flight_offer, :activate
      update :deactivate_travel_flight_offer, :deactivate
      update :expire_travel_flight_offer, :expire
      destroy :delete_travel_flight_offer, :destroy
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
      description "宿主商城 ID，仅用于宿主侧隔离和桥接上下文"
    end
    attribute :supplier_code, :string do
      allow_nil? false
      public? true
      description "供应商编码"
    end
    attribute :itinerary_code, :string do
      allow_nil? false
      public? true
      description "行程编码"
    end
    attribute :flight_no, :string do
      allow_nil? false
      public? true
      description "航班号"
    end
    attribute :departure_airport_code, :string do
      allow_nil? false
      public? true
      description "出发机场编码"
    end
    attribute :arrival_airport_code, :string do
      allow_nil? false
      public? true
      description "到达机场编码"
    end
    attribute :departure_at, :utc_datetime do
      allow_nil? false
      public? true
      description "起飞时间"
    end
    attribute :arrival_at, :utc_datetime do
      allow_nil? false
      public? true
      description "到达时间"
    end
    attribute :cabin_class, :string do
      allow_nil? false
      public? true
      description "舱等"
    end
    attribute :fare_family, :string do
      public? true
      description "运价族"
    end
    attribute :listed_price, :decimal do
      allow_nil? false
      public? true
      description "对客展示价快照"
    end
    attribute :settlement_price, :decimal do
      public? true
      description "结算价快照"
    end
    attribute :currency, :string do
      default "CNY"
      public? true
    end
    attribute :seats_available, :integer do
      default 0
      public? true
      description "可售座位快照"
    end
    attribute :baggage_policy, :string do
      public? true
      description "行李规则快照"
    end
    attribute :refund_change_policy, :string do
      public? true
      description "退改规则快照"
    end
    attribute :sale_status, :atom do
      constraints one_of: [:draft, :active, :inactive, :expired]
      default :draft
      public? true
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :departure_airport_ref, UniboV4.Ecommerce.TravelAirport do
      public? true
    end
    belongs_to :arrival_airport_ref, UniboV4.Ecommerce.TravelAirport do
      public? true
    end
    belongs_to :airline_ref, UniboV4.Travel.TravelAirline do
      public? true
    end
    belongs_to :cabin_class_ref, UniboV4.Travel.TravelCabinClass do
      public? true
    end
    has_many :orders, UniboV4.Travel.TravelOrder do
      public? true
      destination_attribute :flight_offer_id
    end
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:tenant_id, :host_shop_id, :supplier_code, :itinerary_code, :flight_no, :airline_ref_id, :departure_airport_code, :departure_airport_ref_id, :arrival_airport_code, :arrival_airport_ref_id, :departure_at, :arrival_at, :cabin_class, :cabin_class_ref_id, :fare_family, :listed_price, :settlement_price, :currency, :seats_available, :baggage_policy, :refund_change_policy, :sale_status]
      validate present(:tenant_id)
      validate present(:supplier_code)
      validate present(:itinerary_code)
      validate present(:flight_no)
      validate present(:departure_airport_code)
      validate present(:arrival_airport_code)
      validate present(:cabin_class)
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:airline_ref_id, :departure_airport_ref_id, :arrival_airport_ref_id, :cabin_class_ref_id, :listed_price, :settlement_price, :currency, :seats_available, :baggage_policy, :refund_change_policy, :fare_family]
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :activate do
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :sale_status)
        if current in [:draft, :inactive] do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :sale_status, message: "must be one of %{values}", vars: %{values: [:draft, :inactive]}))
        end
      end
      # message: "只有草稿或停用中的 offer 可以 activate"
      change set_attribute(:sale_status, :active)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :deactivate do
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :sale_status)
        if current == :active do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :sale_status, message: "must equal %{value}", vars: %{value: :active}))
        end
      end
      # message: "只有 active 状态的 offer 可以 deactivate 或 expire"
      change set_attribute(:sale_status, :inactive)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :expire do
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :sale_status)
        if current == :active do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :sale_status, message: "must equal %{value}", vars: %{value: :active}))
        end
      end
      # message: "只有 active 状态的 offer 可以 deactivate 或 expire"
      change set_attribute(:sale_status, :expired)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  validations do
    validate compare(:listed_price, greater_than_or_equal_to: 0)
    validate compare(:settlement_price, greater_than_or_equal_to: 0)
    validate compare(:seats_available, greater_than_or_equal_to: 0)
  end

  identities do
    identity :unique_flight_offer_snapshot, [:tenant_id, :supplier_code, :itinerary_code, :flight_no, :departure_at, :cabin_class]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
    archive_related [:orders]
  end

end
