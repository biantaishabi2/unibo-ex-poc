# Workflow: vacation_offer_lifecycle — 度假 offer 生命周期
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
defmodule UniboExPoc.Travel.VacationOffer do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Travel,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource],
    notifiers: [UniboExPoc.Travel.VacationOffer.Notifier]

  resource do
    description "度假可售 offer，承载套餐、出发日期和预订规则快照"
  end

  postgres do
    table "travel_vacation_offers"
    repo UniboExPoc.Repo
  end

  multitenancy do
    strategy :attribute
    attribute :tenant_id
  end

  graphql do
    type :travel_vacation_offer

    queries do
      get :get_travel_vacation_offer, :read
      list :list_travel_vacation_offers, :read
    end

    mutations do
      create :create_travel_vacation_offer, :create
      update :update_travel_vacation_offer, :update
      update :activate_travel_vacation_offer, :activate
      update :deactivate_travel_vacation_offer, :deactivate
      update :expire_travel_vacation_offer, :expire
      destroy :delete_travel_vacation_offer, :destroy
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
    attribute :package_code, :string do
      allow_nil? false
      public? true
      description "套餐编码"
    end
    attribute :package_name, :string do
      allow_nil? false
      public? true
      description "套餐名称"
    end
    attribute :package_type, :atom do
      constraints one_of: [:group_tour, :free_travel, :ticket_hotel, :custom]
      default :group_tour
      public? true
      description "套餐类型"
    end
    attribute :departure_city_code, :string do
      allow_nil? false
      public? true
      description "出发城市编码"
    end
    attribute :destination_code, :string do
      allow_nil? false
      public? true
      description "目的地编码"
    end
    attribute :start_date, :date do
      allow_nil? false
      public? true
      description "出行开始日期"
    end
    attribute :end_date, :date do
      allow_nil? false
      public? true
      description "出行结束日期"
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
    attribute :inventory_count, :integer do
      default 0
      public? true
      description "可售库存快照"
    end
    attribute :booking_rules, :string do
      public? true
      description "预订规则快照"
    end
    attribute :cancellation_policy, :string do
      public? true
      description "取消规则快照"
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
    belongs_to :departure_city_ref, UniboExPoc.Ecommerce.TravelCity do
      public? false
    end
    belongs_to :destination_ref, UniboExPoc.Ecommerce.TravelCity do
      public? false
    end
    has_many :orders, UniboExPoc.Travel.TravelOrder do
      public? true
      destination_attribute :vacation_offer_id
    end
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:tenant_id, :host_shop_id, :supplier_code, :package_code, :package_name, :package_type, :departure_city_code, :destination_code, :start_date, :end_date, :listed_price, :settlement_price, :currency, :inventory_count, :booking_rules, :cancellation_policy, :sale_status]
      validate present(:tenant_id)
      validate present(:supplier_code)
      validate present(:package_code)
      validate present(:package_name)
      validate present(:departure_city_code)
      validate present(:destination_code)
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
      accept [:package_name, :package_type, :listed_price, :settlement_price, :currency, :inventory_count, :booking_rules, :cancellation_policy]
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
    validate compare(:listed_price, greater_than_or_equal_to: 0)
    validate compare(:settlement_price, greater_than_or_equal_to: 0)
    validate compare(:inventory_count, greater_than_or_equal_to: 0)
  end

  identities do
    identity :unique_vacation_offer_snapshot, [:tenant_id, :supplier_code, :package_code, :start_date, :end_date]
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
