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
defmodule UniboV4.Lunch.LunchOrder do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Lunch,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource],
    notifiers: [UniboV4.Lunch.LunchOrder.Notifier]

  postgres do
    table "lunch_orders"
    repo UniboV4.Repo
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
    end
    attribute :date, :date do
      allow_nil? false
      default &Date.utc_today/0
      public? true
    end
    attribute :note, :string, public?: true
    attribute :state, :atom do
      allow_nil? false
      constraints one_of: [:new, :ordered, :sent, :confirmed, :cancelled]
      default :new
      public? true
    end
    attribute :active, :boolean do
      default true
      public? true
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  calculations do
    # TODO: 不支持的 calculation 表达式 :price
    # TODO: 不支持的 calculation 表达式 :display_toppings
    # TODO: 不支持的 calculation 表达式 :available_today
    # TODO: 不支持的 calculation 表达式 :order_deadline_passed
  end

  relationships do
    belongs_to :product, UniboV4.Lunch.LunchProduct do
      public? true
      allow_nil? false
    end
    belongs_to :user, UniboV4.Lunch.User do
      public? true
      allow_nil? false
    end
    belongs_to :lunch_location, UniboV4.Lunch.LunchLocation do
      public? true
    end
    many_to_many :topping_ids_1, UniboV4.Lunch.LunchTopping do
      public? true
      through UniboV4.Lunch.LunchOrderTopping1Link
    end
    many_to_many :topping_ids_2, UniboV4.Lunch.LunchTopping do
      public? true
      through UniboV4.Lunch.LunchOrderTopping2Link
    end
    many_to_many :topping_ids_3, UniboV4.Lunch.LunchTopping do
      public? true
      through UniboV4.Lunch.LunchOrderTopping3Link
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
      # TODO: 不支持的 action 内校验规则 custom
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
      primary? true
      accept [:quantity]
      # TODO: 不支持的 change effect deactivate_when_zero
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
      # skipped: validate custom : (incompatible with bulk update atomic path)
      # skipped: validate custom : (incompatible with bulk update atomic path)
      # skipped: validate custom : (incompatible with bulk update atomic path)
      # skipped: validate custom : (incompatible with bulk update atomic path)
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

end
