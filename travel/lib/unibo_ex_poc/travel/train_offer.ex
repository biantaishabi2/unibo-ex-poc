# Workflow: train_offer_lifecycle — 火车票 offer 生命周期
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
defmodule UniboExPoc.Travel.TrainOffer do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Travel,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource],
    notifiers: [UniboExPoc.Travel.TrainOffer.Notifier]

  resource do
    description "火车票可售 offer，承载车次、席别、候补和退改规则快照"
  end

  postgres do
    table "travel_train_offers"
    repo UniboExPoc.Repo
  end

  multitenancy do
    strategy :attribute
    attribute :tenant_id
  end

  graphql do
    type :travel_train_offer

    queries do
      get :get_travel_train_offer, :read
      list :list_travel_train_offers, :read
    end

    mutations do
      create :create_travel_train_offer, :create
      update :update_travel_train_offer, :update
      update :activate_travel_train_offer, :activate
      update :deactivate_travel_train_offer, :deactivate
      update :expire_travel_train_offer, :expire
      destroy :delete_travel_train_offer, :destroy
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
    attribute :train_no, :string do
      allow_nil? false
      public? true
      description "车次号"
    end
    attribute :departure_station_code, :string do
      allow_nil? false
      public? true
      description "出发站编码"
    end
    attribute :departure_station_name, :string do
      allow_nil? false
      public? true
      description "出发站名称"
    end
    attribute :arrival_station_code, :string do
      allow_nil? false
      public? true
      description "到达站编码"
    end
    attribute :arrival_station_name, :string do
      allow_nil? false
      public? true
      description "到达站名称"
    end
    attribute :travel_date, :date do
      allow_nil? false
      public? true
      description "乘车日期"
    end
    attribute :departure_at, :utc_datetime do
      allow_nil? false
      public? true
      description "发车时间"
    end
    attribute :arrival_at, :utc_datetime do
      allow_nil? false
      public? true
      description "到达时间"
    end
    attribute :seat_class, :string do
      allow_nil? false
      public? true
      description "席别名称"
    end
    attribute :seat_code, :string do
      allow_nil? false
      public? true
      description "席别编码"
    end
    attribute :is_no_seat, :boolean do
      default false
      public? true
      description "是否无座票"
    end
    attribute :inventory_status, :atom do
      constraints one_of: [:available, :waitlist_only, :sold_out, :unavailable]
      default :unavailable
      public? true
      description "余票或候补可用状态"
    end
    attribute :waitlist_supported, :boolean do
      default false
      public? true
      description "是否支持候补"
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
    attribute :booking_rules_snapshot, :string do
      public? true
      description "预订规则快照"
    end
    attribute :change_rules_snapshot, :string do
      public? true
      description "改签规则快照"
    end
    attribute :refund_rules_snapshot, :string do
      public? true
      description "退票规则快照"
    end
    attribute :sale_status, :atom do
      constraints one_of: [:draft, :active, :inactive, :expired]
      default :draft
      public? true
      description "可售状态"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :departure_station_ref, UniboExPoc.Ecommerce.TravelStation do
      public? true
    end
    belongs_to :arrival_station_ref, UniboExPoc.Ecommerce.TravelStation do
      public? true
    end
    has_many :orders, UniboExPoc.Travel.TravelOrder do
      public? true
      destination_attribute :train_offer_id
    end
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:tenant_id, :host_shop_id, :supplier_code, :train_no, :departure_station_code, :departure_station_ref_id, :departure_station_name, :arrival_station_code, :arrival_station_ref_id, :arrival_station_name, :travel_date, :departure_at, :arrival_at, :seat_class, :seat_code, :is_no_seat, :inventory_status, :waitlist_supported, :listed_price, :settlement_price, :currency, :booking_rules_snapshot, :change_rules_snapshot, :refund_rules_snapshot, :sale_status]
      validate present(:tenant_id)
      validate present(:supplier_code)
      validate present(:train_no)
      validate present(:departure_station_code)
      validate present(:arrival_station_code)
      validate present(:seat_class)
      validate present(:seat_code)
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:departure_station_ref_id, :arrival_station_ref_id, :departure_station_name, :arrival_station_name, :departure_at, :arrival_at, :seat_class, :is_no_seat, :inventory_status, :waitlist_supported, :listed_price, :settlement_price, :currency, :booking_rules_snapshot, :change_rules_snapshot, :refund_rules_snapshot]
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
  end

  identities do
    identity :unique_train_offer_snapshot, [:tenant_id, :supplier_code, :train_no, :departure_station_code, :arrival_station_code, :travel_date, :seat_code, :is_no_seat]
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
