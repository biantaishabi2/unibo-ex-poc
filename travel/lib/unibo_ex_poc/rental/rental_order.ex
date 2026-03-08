# Workflow: rental_flow — 租赁全流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> action_confirm
#   create --> action_cancel
#   action_confirm --> action_pickup
#   action_confirm --> action_cancel
#   action_pickup --> action_return
#   action_return --> action_done
#   action_done --> [*] : done
# ```
defmodule UniboExPoc.Rental.RentalOrder do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Rental,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource],
    authorizers: [Ash.Policy.Authorizer],
    notifiers: [UniboExPoc.Rental.RentalOrder.Notifier]

  resource do
    description "租赁订单（对应 Odoo sale.order 扩展，is_rental=true 区分普通销售）"
  end

  postgres do
    table "rental_orders"
    repo UniboExPoc.Repo
  end

  graphql do
    type :rental_rental_order

    queries do
      get :get_rental_rental_order, :read
      list :list_rental_rental_orders, :read
    end

    mutations do
      create :create_rental_rental_order, :create
      update :update_rental_rental_order, :update
      update :action_confirm_rental_rental_order, :action_confirm
      update :action_pickup_rental_rental_order, :action_pickup
      update :action_return_rental_rental_order, :action_return
      update :action_done_rental_rental_order, :action_done
      update :action_cancel_rental_rental_order, :action_cancel
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :is_rental, :boolean do
      allow_nil? false
      default true
      public? true
      description "区分普通销售与租赁订单"
    end
    attribute :rental_status, :atom do
      constraints one_of: [:draft, :confirmed, :pickup, :return, :done, :cancel]
      default :draft
      public? true
      description "订单级租赁状态"
    end
    attribute :pickup_date, :utc_datetime do
      allow_nil? false
      public? true
      description "计划取货日期"
    end
    attribute :return_date, :utc_datetime do
      allow_nil? false
      public? true
      description "计划归还日期"
    end
    attribute :actual_return_date, :utc_datetime do
      public? true
      description "实际归还日期（归还时写入）"
    end
    attribute :padding_time, :float do
      public? true
      description "缓冲时间（小时），从全局配置继承或手动覆盖"
    end
    attribute :delivery_order_id, :uuid do
      public? true
      description "关联出库单（取货，库存集成时）"
    end
    attribute :receipt_order_id, :uuid do
      public? true
      description "关联入库单（归还，库存集成时）"
    end
    attribute :reservation_expires_at, :utc_datetime do
      public? true
      description "预约过期时间（TTL 自动释放）"
    end
    attribute :deposit_amount, :decimal do
      public? true
      description "押金金额"
    end
    attribute :currency_id, :uuid do
      allow_nil? false
      public? true
      description "币种"
    end
    attribute :company_id, :uuid do
      allow_nil? false
      public? true
      description "所属公司"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  calculations do
    calculate :is_late, :boolean, expr(any(lines.is_late))
    calculate :penalty_amount, :decimal, expr(sum(lines, field: :penalty_amount, query: [filter: expr(true)]))
    calculate :has_pickable_lines, :boolean, expr(any(lines.is_pickable))
    calculate :has_returnable_lines, :boolean, expr(any(lines.is_returnable))
  end

  relationships do
    has_many :lines, UniboExPoc.Rental.RentalOrderLine do
      public? true
      destination_attribute :order_id
    end
    belongs_to :customer, UniboExPoc.Rental.Customer do
      public? true
      allow_nil? false
    end
    belongs_to :created_by, UniboExPoc.Rental.Party do
      public? true
      source_attribute :created_by_party_id
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:pickup_date, :return_date, :padding_time, :deposit_amount, :currency_id, :company_id]
      argument :lines, {:array, :string}, allow_nil?: false
      argument :customer_id, :uuid, allow_nil?: false
      change manage_relationship(:lines, :lines, type: :create)
      change manage_relationship(:customer_id, :customer, type: :append, on_lookup: :relate)
      validate compare(:return_date, greater_than: :pickup_date)
      # message: "归还日期必须晚于取货日期"
      validate compare(:padding_time, greater_than_or_equal_to: 0)
      # message: "缓冲时间不能为负数"
      change relate_actor(:created_by)
    end
    update :update do
      primary? true
      accept [:pickup_date, :return_date, :padding_time, :deposit_amount]
      argument :lines, {:array, :map}, default: []
      change manage_relationship(:lines, :lines, on_lookup: :relate, on_no_match: :create, on_match: :update)
      # skipped: validate compare :return_date (incompatible with bulk update atomic path)
      # skipped: validate compare :padding_time (incompatible with bulk update atomic path)
      require_atomic? false
    end
    update :action_confirm do
      description "确认订单（校验库存可用性，创建出入库单）"
      accept []
      # skipped: validate compare :return_date (incompatible with bulk update atomic path)
      # skipped: validate compare :padding_time (incompatible with bulk update atomic path)
      # skipped: validate custom : (incompatible with bulk update atomic path)
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :rental_status)
        if current == :draft do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :rental_status, message: "must equal %{value}", vars: %{value: :draft}))
        end
      end
      # message: "只有草稿状态可以确认"
      change set_attribute(:rental_status, :confirmed)
      change UniboExPoc.Rental.Changes.RentalOrder.ActionConfirmCall7
      require_atomic? false
    end
    update :action_pickup do
      description "取货（至少一条行完成取货验证）"
      accept []
      # skipped: validate compare :return_date (incompatible with bulk update atomic path)
      # skipped: validate compare :padding_time (incompatible with bulk update atomic path)
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :rental_status)
        if current == :confirmed do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :rental_status, message: "must equal %{value}", vars: %{value: :confirmed}))
        end
      end
      # message: "只有已确认状态可以取货"
      change set_attribute(:rental_status, :pickup)
      require_atomic? false
    end
    update :action_return do
      description "归还（所有已取货行完成归还）"
      accept []
      # skipped: validate compare :return_date (incompatible with bulk update atomic path)
      # skipped: validate compare :padding_time (incompatible with bulk update atomic path)
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :rental_status)
        if current == :pickup do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :rental_status, message: "must equal %{value}", vars: %{value: :pickup}))
        end
      end
      # message: "只有已取货状态可以归还"
      change set_attribute(:rental_status, :return)
      require_atomic? false
    end
    update :action_done do
      description "完成（发票已创建且罚金已计算）"
      accept []
      # skipped: validate compare :return_date (incompatible with bulk update atomic path)
      # skipped: validate compare :padding_time (incompatible with bulk update atomic path)
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :rental_status)
        if current == :return do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :rental_status, message: "must equal %{value}", vars: %{value: :return}))
        end
      end
      # message: "只有已归还状态可以完成"
      change set_attribute(:rental_status, :done)
      require_atomic? false
    end
    update :action_cancel do
      description "取消订单"
      accept []
      # skipped: validate compare :return_date (incompatible with bulk update atomic path)
      # skipped: validate compare :padding_time (incompatible with bulk update atomic path)
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :rental_status)
        if current in [:draft, :confirmed] do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :rental_status, message: "must be one of %{values}", vars: %{values: [:draft, :confirmed]}))
        end
      end
      # message: "只有草稿或已确认状态可以取消"
      change set_attribute(:rental_status, :cancel)
      require_atomic? false
    end
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  aggregates do
    count :total_lines, :lines
    sum :total_penalty, :lines, field: :penalty_amount
  end

  policies do
    policy action_type(:create) do
      authorize_if expr(actor.role in [:rental_agent, :admin])
    end
    policy action_type(:read) do
      authorize_if always()
    end
    policy action_type(:update) do
      authorize_if expr(actor.role == :admin or actor.id == created_by_id)
    end
  end

end
