# Workflow: rental_order_line_lifecycle — 租赁订单行生命周期
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> validate_pickup
#   update --> validate_pickup
#   validate_pickup --> validate_return
#   validate_return --> finalize
#   finalize --> [*]
# ```
defmodule UniboV4.Rental.RentalOrderLine do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Rental,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "rental_order_lines"
    repo UniboV4.Repo
  end

  graphql do
    type :rental_rental_order_line

    mutations do
      create :create_rental_rental_order_line, :create
      update :update_rental_rental_order_line, :update
      update :validate_pickup_rental_rental_order_line, :validate_pickup
      update :validate_return_rental_rental_order_line, :validate_return
      update :finalize_rental_rental_order_line, :finalize
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :is_rental, :boolean do
      allow_nil? false
      default true
      public? true
    end
    attribute :rental_status, :atom do
      constraints one_of: [:draft, :pickup, :return, :returned]
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
    attribute :qty_delivered, :float do
      default 0
      public? true
    end
    attribute :qty_returned, :float do
      default 0
      public? true
    end
    attribute :product_uom_qty, :float do
      allow_nil? false
      public? true
    end
    attribute :duration_unit, :atom do
      constraints one_of: [:hour, :day, :week, :month, :year]
      public? true
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  calculations do
    # TODO: 不支持的 calculation 表达式 :qty_remaining
    # TODO: 不支持的 calculation 表达式 :rental_price
    # TODO: 不支持的 calculation 表达式 :penalty_amount
    # TODO: 不支持的 calculation 表达式 :is_late
    # TODO: 不支持的 calculation 表达式 :duration
    # TODO: 不支持的 calculation 表达式 :is_pickable
    # TODO: 不支持的 calculation 表达式 :is_returnable
  end

  relationships do
    belongs_to :order, UniboV4.Rental.RentalOrder do
      public? true
      allow_nil? false
    end
    belongs_to :product, UniboV4.Rental.Product do
      public? true
      allow_nil? false
    end
    belongs_to :pricing_rule, UniboV4.Rental.RentalPricing do
      public? true
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:is_rental, :pickup_date, :return_date, :product_uom_qty, :duration_unit]
      argument :product_id, :uuid, allow_nil?: false
      argument :order_id, :uuid, allow_nil?: false
      change manage_relationship(:order_id, :order, type: :append, on_lookup: :relate)
      change manage_relationship(:product_id, :product, type: :append, on_lookup: :relate)
      # TODO: 不支持的 action 内校验规则 custom
    end
    update :update do
      primary? true
      accept [:pickup_date, :return_date, :product_uom_qty, :duration_unit]
      # TODO: 不支持的 change effect side_effect
    end
    update :validate_pickup do
      argument :qty, :float, allow_nil?: false
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :rental_status)
        if current == :draft do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :rental_status, message: "must equal %{value}", vars: %{value: :draft}))
        end
      end
      # message: "只有草稿状态可以取货"
      # TODO: 不支持的表达式类型
      change set_attribute(:rental_status, :pickup)
      # TODO: 不支持的 change effect side_effect
      require_atomic? false
    end
    update :validate_return do
      argument :qty, :float, allow_nil?: false
      argument :actual_return_date, :utc_datetime, allow_nil?: false
      # skipped: validate compare :qty_returned (incompatible with bulk update atomic path)
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :rental_status)
        if current == :pickup do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :rental_status, message: "must equal %{value}", vars: %{value: :pickup}))
        end
      end
      # message: "只有已取货状态可以归还"
      # TODO: 不支持的表达式类型
      # TODO: 不支持的表达式类型
      change set_attribute(:rental_status, :return)
      # TODO: 不支持的 change effect side_effect
      # TODO: 不支持的 change effect side_effect
      require_atomic? false
    end
    update :finalize do
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :rental_status)
        if current == :return do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :rental_status, message: "must equal %{value}", vars: %{value: :return}))
        end
      end
      # message: "只有已归还状态可以完成"
      change set_attribute(:rental_status, :returned)
      # TODO: 不支持的 change effect side_effect
      require_atomic? false
    end
  end

end
