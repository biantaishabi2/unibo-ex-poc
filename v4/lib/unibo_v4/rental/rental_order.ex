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
defmodule UniboV4.Rental.RentalOrder do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Rental,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer],
    notifiers: [UniboV4.Rental.RentalOrder.Notifier]

  postgres do
    table "rental_orders"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :is_rental, :boolean do
      allow_nil? false
      default true
      public? true
    end
    attribute :rental_status, :atom do
      constraints one_of: [:draft, :confirmed, :pickup, :return, :done, :cancel]
      default :draft
      public? true
    end
    attribute :pickup_date, :utc_datetime do
      allow_nil? false
      public? true
    end
    attribute :return_date, :utc_datetime do
      allow_nil? false
      public? true
    end
    attribute :actual_return_date, :utc_datetime, public?: true
    attribute :padding_time, :float, public?: true
    attribute :delivery_order_id, :uuid, public?: true
    attribute :receipt_order_id, :uuid, public?: true
    attribute :reservation_expires_at, :utc_datetime, public?: true
    attribute :deposit_amount, :decimal, public?: true
    attribute :currency_id, :uuid do
      allow_nil? false
      public? true
    end
    attribute :company_id, :uuid do
      allow_nil? false
      public? true
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  calculations do
    # TODO: 不支持的 calculation 表达式 :is_late
    calculate :penalty_amount, :decimal, expr(sum(lines, field: :penalty_amount, query: [filter: expr(true)]))
    # TODO: 不支持的 calculation 表达式 :has_pickable_lines
    # TODO: 不支持的 calculation 表达式 :has_returnable_lines
  end

  relationships do
    has_many :lines, UniboV4.Rental.RentalOrderLine do
      public? true
      destination_attribute :order_id
    end
    belongs_to :customer, UniboV4.Rental.Customer do
      public? true
      allow_nil? false
    end
    belongs_to :created_by, UniboV4.Rental.User do
      public? true
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
      accept []
      # skipped: validate compare :return_date (incompatible with bulk update atomic path)
      # skipped: validate compare :padding_time (incompatible with bulk update atomic path)
      # skipped: validate custom : (incompatible with bulk update atomic path)
      # skipped: validate custom : (incompatible with bulk update atomic path)
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
      # TODO: 不支持的 change effect side_effect
      require_atomic? false
    end
    update :action_pickup do
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
    policy always() do
      authorize_if always()
    end
  end

end
