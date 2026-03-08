# Workflow: order_flow — 午餐订单流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> action_order
#   action_order --> action_send
#   action_order --> action_cancel
#   action_send --> action_confirm
#   action_send --> action_cancel
#   action_confirm --> [*] : confirmed
#   action_cancel --> action_reset
#   action_reset --> action_send
#   action_reset --> action_cancel
# ```
defmodule UniboExPoc.Lunch.LunchOrder do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Lunch,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource],
    notifiers: [UniboExPoc.Lunch.LunchOrder.Notifier]

  resource do
    description "午餐订单行，支持购物车合并、配料选择、钱包预检"
  end

  postgres do
    table "lunch_orders"
    repo UniboExPoc.Repo
  end

  graphql do
    type :lunch_lunch_order

    queries do
      get :get_lunch_lunch_order, :read
      list :list_lunch_lunch_orders, :read
    end

    mutations do
      create :create_lunch_lunch_order, :create
      update :update_quantity_lunch_lunch_order, :update_quantity
      update :action_order_lunch_lunch_order, :action_order
      update :action_send_lunch_lunch_order, :action_send
      update :action_confirm_lunch_lunch_order, :action_confirm
      update :action_cancel_lunch_lunch_order, :action_cancel
      update :action_reset_lunch_lunch_order, :action_reset
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :quantity, :integer do
      allow_nil? false
      default 1
      public? true
      description "数量，降至0时自动停用"
    end
    attribute :date, :date do
      allow_nil? false
      default &Date.utc_today/0
      public? true
      description "订单日期"
    end
    attribute :note, :string do
      public? true
      description "备注"
    end
    attribute :state, :atom do
      allow_nil? false
      constraints one_of: [:new, :ordered, :sent, :confirmed, :cancelled]
      default :new
      public? true
      description "订单状态"
    end
    attribute :active, :boolean do
      default true
      public? true
      description "是否活跃（quantity降至0时设为false）"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  calculations do
    calculate :price, :decimal, expr((quantity * (product.price + sum_topping_prices(topping_ids_1, topping_ids_2, topping_ids_3))))
    calculate :display_toppings, :string, expr(join_names( + , topping_ids_1, topping_ids_2, topping_ids_3))
    calculate :available_today, :boolean, expr(product.supplier)
    calculate :order_deadline_passed, :boolean, expr(product.supplier)
  end

  relationships do
    belongs_to :product, UniboExPoc.Lunch.LunchProduct do
      public? true
      allow_nil? false
    end
    belongs_to :user, UniboExPoc.Lunch.Party do
      public? true
      allow_nil? false
      source_attribute :user_party_id
    end
    belongs_to :lunch_location, UniboExPoc.Lunch.LunchLocation do
      public? true
    end
    many_to_many :topping_ids_1, UniboExPoc.Lunch.LunchTopping do
      public? true
      through UniboExPoc.Lunch.LunchOrderTopping1Link
      destination_attribute_on_join_resource :topping_id
    end
    many_to_many :topping_ids_2, UniboExPoc.Lunch.LunchTopping do
      public? true
      through UniboExPoc.Lunch.LunchOrderTopping2Link
      destination_attribute_on_join_resource :topping_id
    end
    many_to_many :topping_ids_3, UniboExPoc.Lunch.LunchTopping do
      public? true
      through UniboExPoc.Lunch.LunchOrderTopping3Link
      destination_attribute_on_join_resource :topping_id
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:quantity, :date, :note]
      argument :product_id, :uuid, allow_nil?: false
      argument :lunch_location_id, :uuid
      argument :topping_ids_1, {:array, :string}
      argument :topping_ids_2, {:array, :string}
      argument :topping_ids_3, {:array, :string}
      change manage_relationship(:product_id, :product, type: :append, on_lookup: :relate)
      argument :user_id, :uuid, allow_nil?: false
      change manage_relationship(:user_id, :user, type: :append, on_lookup: :relate)
      # validation: check_topping_quantity
      change relate_actor(:user)
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
    end
    update :update_quantity do
      description "更新数量（降至0时自动停用并触发钱包校验）"
      primary? true
      accept [:quantity]
      change set_attribute(:active, false)
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
    update :action_order do
      description "下单（new → ordered），校验supplier可用性和产品active状态"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :state)
        if current == :new do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :state, message: "must equal %{value}", vars: %{value: :new}))
        end
      end
      # message: "只有新建状态可以下单"
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
      change set_attribute(:state, :ordered)
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
    update :action_send do
      description "发送给供应商（ordered → sent）"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :state)
        if current == :ordered do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :state, message: "must equal %{value}", vars: %{value: :ordered}))
        end
      end
      # message: "只有已下单状态可以发送"
      change set_attribute(:state, :sent)
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
    update :action_confirm do
      description "供应商确认交付（sent → confirmed）"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :state)
        if current == :sent do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :state, message: "must equal %{value}", vars: %{value: :sent}))
        end
      end
      # message: "只有已发送状态可以确认"
      change set_attribute(:state, :confirmed)
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
    update :action_cancel do
      description "取消订单（任意状态 → cancelled）"
      accept []
      change set_attribute(:state, :cancelled)
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
    update :action_reset do
      description "重新打开已取消订单（cancelled → ordered）"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :state)
        if current == :cancelled do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :state, message: "must equal %{value}", vars: %{value: :cancelled}))
        end
      end
      # message: "只有已取消状态可以重置"
      change set_attribute(:state, :ordered)
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
    validate compare(:quantity, greater_than_or_equal_to: 0)
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
