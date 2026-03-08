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
defmodule UniboExPoc.Rental.RentalOrderLine do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Rental,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource]

  resource do
    description "租赁订单行（支持部分取货/归还，行级独立状态）"
  end

  postgres do
    table "rental_order_lines"
    repo UniboExPoc.Repo
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
      description "是否为租赁行"
    end
    attribute :rental_status, :atom do
      constraints one_of: [:draft, :pickup, :return, :returned]
      default :draft
      public? true
      description "行级租赁状态"
    end
    attribute :pickup_date, :utc_datetime do
      allow_nil? false
      public? true
      description "行级取货日期（可与订单头不同，支持部分取货）"
    end
    attribute :return_date, :utc_datetime do
      allow_nil? false
      public? true
      description "行级归还日期"
    end
    attribute :actual_return_date, :utc_datetime do
      public? true
      description "实际归还时间"
    end
    attribute :qty_delivered, :float do
      default 0
      public? true
      description "已取货数量"
    end
    attribute :qty_returned, :float do
      default 0
      public? true
      description "已归还数量"
    end
    attribute :product_uom_qty, :float do
      allow_nil? false
      public? true
      description "租赁数量"
    end
    attribute :duration_unit, :atom do
      constraints one_of: [:hour, :day, :week, :month, :year]
      public? true
      description "时长单位"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  calculations do
    calculate :qty_remaining, :float, expr((qty_delivered - qty_returned))
    calculate :rental_price, :decimal, expr(compute_rental_price(self))
    calculate :penalty_amount, :decimal, expr(compute_penalty(self, actual_return_date))
    calculate :is_late, :boolean, {UniboExPoc.Rental.Calculations.RentalOrderLine.IsLate, []}
    calculate :duration, :float, expr(date_diff(return_date, pickup_date, duration_unit))
    calculate :is_pickable, :boolean, expr(rental_status == draft)
    calculate :is_returnable, :boolean, expr((rental_status == pickup and qty_remaining > 0))
  end

  relationships do
    belongs_to :order, UniboExPoc.Rental.RentalOrder do
      public? true
      allow_nil? false
    end
    belongs_to :product, UniboExPoc.Rental.Product do
      public? true
      allow_nil? false
    end
    belongs_to :pricing_rule, UniboExPoc.Rental.RentalPricing do
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
      validate compare(:rent_ok, equal_to: true)
      # message: "该产品未启用租赁功能"
    end
    update :update do
      primary? true
      accept [:pickup_date, :return_date, :product_uom_qty, :duration_unit]
      change UniboExPoc.Rental.Changes.RentalOrderLine.UpdateCall8
      require_atomic? false
    end
    update :validate_pickup do
      description "取货验证（产品已交付给客户）"
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
      change fn changeset, _context ->
        qty_delivered = Ash.Changeset.get_attribute(changeset, :qty_delivered)

        if qty_delivered do
          Ash.Changeset.force_change_attribute(changeset, :qty_delivered, (qty_delivered + ^arg(:qty)))
        else
          changeset
        end
      end
      change set_attribute(:rental_status, :pickup)
      change UniboExPoc.Rental.Changes.RentalOrderLine.ValidatePickupCall8
      require_atomic? false
    end
    update :validate_return do
      description "归还验证（客户已归还产品）"
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
      change fn changeset, _context ->
        qty_returned = Ash.Changeset.get_attribute(changeset, :qty_returned)

        if qty_returned do
          Ash.Changeset.force_change_attribute(changeset, :qty_returned, (qty_returned + ^arg(:qty)))
        else
          changeset
        end
      end
      change set_attribute(:actual_return_date, ^arg(:actual_return_date))
      change set_attribute(:rental_status, :return)
      change UniboExPoc.Rental.Changes.RentalOrderLine.ValidateReturnCall7
      change UniboExPoc.Rental.Changes.RentalOrderLine.ValidateReturnCall8
      require_atomic? false
    end
    update :finalize do
      description "完成归还流程（库存已恢复）"
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
      change UniboExPoc.Rental.Changes.RentalOrderLine.FinalizeCall8
      require_atomic? false
    end
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
