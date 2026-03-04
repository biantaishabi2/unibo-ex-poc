# Workflow: order_flow — POS 订单流程（draft→paid→done→invoiced / draft→cancel）
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> pay
#   create --> cancel
#   pay --> done
#   done --> invoice
#   done --> refund
#   invoice --> refund
#   refund --> [*]
#   cancel --> destroy
#   destroy --> [*]
# ```
defmodule UniboV4.POS.PosOrder do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.POS,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "pos_orders"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :order_number, :string do
      allow_nil? false
      public? true
    end
    attribute :status, :atom do
      constraints one_of: [:draft, :paid, :done, :invoiced, :cancel]
      default :draft
      public? true
    end
    attribute :amount_total, :decimal, public?: true
    attribute :amount_tax, :decimal, public?: true
    attribute :amount_untaxed, :decimal, public?: true
    attribute :amount_paid, :decimal, public?: true
    attribute :amount_change, :decimal, public?: true
    attribute :discount_amount, :decimal do
      default 0
      public? true
    end
    attribute :currency_rate, :decimal, public?: true
    attribute :is_invoiced, :boolean, public?: true
    attribute :is_refunded, :boolean, public?: true
    attribute :customer_count, :integer do
      default 0
      public? true
    end
    attribute :margin, :decimal, public?: true
    attribute :margin_percent, :decimal, public?: true
    attribute :order_date, :utc_datetime do
      allow_nil? false
      public? true
    end
    attribute :notes, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :items, UniboV4.POS.PosOrderLine do
      public? true
      destination_attribute :order_id
    end
    has_many :payments, UniboV4.POS.PosPayment do
      public? true
      destination_attribute :order_id
    end
    belongs_to :session, UniboV4.POS.PosSession do
      public? true
      allow_nil? false
    end
    belongs_to :partner, UniboV4.POS.Partner do
      public? true
    end
    belongs_to :currency, UniboV4.POS.Currency do
      public? true
      allow_nil? false
    end
    belongs_to :fiscal_position, UniboV4.POS.FiscalPosition do
      public? true
    end
    belongs_to :table, UniboV4.POS.RestaurantTable do
      public? true
    end
    belongs_to :refunded_order, UniboV4.POS.PosOrder do
      public? true
    end
    has_many :refund_orders, UniboV4.POS.PosOrder do
      public? true
      destination_attribute :refunded_order_id
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:order_number, :order_date, :discount_amount, :customer_count, :notes]
      argument :items, {:array, :string}, allow_nil?: false
      argument :session_id, :uuid, allow_nil?: false
      argument :table_id, :uuid
      change manage_relationship(:items, :items, type: :create)
      change manage_relationship(:session_id, :session, type: :append, on_lookup: :relate)
      argument :currency_id, :uuid, allow_nil?: false
      change manage_relationship(:currency_id, :currency, type: :append, on_lookup: :relate)
      validate present(:order_number)
      # TODO: 不支持的 action 内校验规则 custom
      # TODO: 跨实体聚合表达式暂不支持
      # TODO: 跨实体聚合表达式暂不支持
      change fn changeset, _context ->
        amount_total = Ash.Changeset.get_attribute(changeset, :amount_total)
        amount_untaxed = Ash.Changeset.get_attribute(changeset, :amount_untaxed)

        if amount_total && amount_untaxed do
          Ash.Changeset.force_change_attribute(changeset, :amount_tax, Decimal.sub(amount_total, amount_untaxed))
        else
          changeset
        end
      end
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
    end
    update :pay do
      accept []
      argument :payments, {:array, :string}, allow_nil?: false
      # skipped: validate custom : (incompatible with bulk update atomic path)
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :draft do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :draft}))
        end
      end
      # message: "只有草稿状态可以付款"
      # TODO: 不支持的 change effect side_effect
      # TODO: 不支持的 change effect side_effect
      change set_attribute(:status, :paid)
      # TODO: 不支持的 change effect side_effect
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
    update :done do
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :paid do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :paid}))
        end
      end
      # message: "只有已付款状态可以标记完成"
      change set_attribute(:status, :done)
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
    update :invoice do
      # skipped: validate present :partner_id (incompatible with bulk update atomic path)
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :done do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :done}))
        end
      end
      # message: "只有完成状态可以开票"
      # TODO: 不支持的 change effect side_effect
      # TODO: 不支持的 change effect side_effect
      change set_attribute(:status, :invoiced)
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
    create :refund do
      accept []
      argument :refund_lines, {:array, :string}
      argument :items, {:array, :map}, default: []
      change manage_relationship(:items, :items, type: :create)
      argument :session_id, :uuid, allow_nil?: false
      change manage_relationship(:session_id, :session, type: :append, on_lookup: :relate)
      argument :currency_id, :uuid, allow_nil?: false
      change manage_relationship(:currency_id, :currency, type: :append, on_lookup: :relate)
      validate present(:order_number)
      # TODO: 不支持的 action 内校验规则 custom
      # TODO: 跨实体聚合表达式暂不支持
      # TODO: 跨实体聚合表达式暂不支持
      change fn changeset, _context ->
        amount_total = Ash.Changeset.get_attribute(changeset, :amount_total)
        amount_untaxed = Ash.Changeset.get_attribute(changeset, :amount_untaxed)

        if amount_total && amount_untaxed do
          Ash.Changeset.force_change_attribute(changeset, :amount_tax, Decimal.sub(amount_total, amount_untaxed))
        else
          changeset
        end
      end
      # TODO: 不支持的 change effect side_effect
      # TODO: 不支持的 change effect side_effect
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
    end
    update :cancel do
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :draft do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :draft}))
        end
      end
      # message: "只有草稿状态可以取消"
      change set_attribute(:status, :cancel)
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
    destroy :destroy do
      validate attribute_in(:status, [:draft, :cancel])
      # message: "仅草稿或取消状态可删除"
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
    end
  end

  identities do
    identity :unique_order_number, [:order_number]
  end

end
