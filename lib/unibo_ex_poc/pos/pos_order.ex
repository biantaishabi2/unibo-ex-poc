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
defmodule UniboExPoc.POS.PosOrder do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.POS,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "POS 订单，支持正常销售、退款、开票完整流程"
  end

  postgres do
    table "pos_orders"
    repo UniboExPoc.Repo
  end

  graphql do
    type :pos_pos_order

    queries do
      get :get_pos_pos_order, :read
      list :list_pos_pos_orders, :read
    end

    mutations do
      create :create_create_pos_pos_order, :create
      create :create_refund_pos_pos_order, :refund
      update :pay_pos_pos_order, :pay
      update :done_pos_pos_order, :done
      update :invoice_pos_pos_order, :invoice
      update :cancel_pos_pos_order, :cancel
      destroy :delete_pos_pos_order, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :order_number, :string do
      allow_nil? false
      public? true
      description "订单号，唯一"
    end
    attribute :status, :atom do
      constraints one_of: [:draft, :paid, :done, :invoiced, :cancel]
      default :draft
      public? true
      description "状态机: draft→paid→done→invoiced, draft→cancel, done→invoiced"
    end
    attribute :amount_total, :decimal do
      public? true
      description "含税总额 = sum(lines.price_subtotal_incl)"
    end
    attribute :amount_tax, :decimal do
      public? true
      description "税额 = sum(lines.price_subtotal_incl) - sum(lines.price_subtotal)"
    end
    attribute :amount_untaxed, :decimal do
      public? true
      description "不含税小计 = sum(lines.price_subtotal)"
    end
    attribute :amount_paid, :decimal do
      public? true
      description "已付金额 = sum(payments.amount)"
    end
    attribute :amount_change, :decimal do
      public? true
      description "找零金额 = max(0, amount_paid - amount_total)"
    end
    attribute :discount_amount, :decimal do
      default 0
      public? true
      description "折扣总额"
    end
    attribute :currency_rate, :decimal do
      public? true
      description "订单币种→公司本币汇率（当日）"
    end
    attribute :is_invoiced, :boolean do
      public? true
      description "是否已开发票（account_move_id IS NOT NULL）"
    end
    attribute :is_refunded, :boolean do
      public? true
      description "是否全部退款"
    end
    attribute :customer_count, :integer do
      default 0
      public? true
      description "就餐人数"
    end
    attribute :margin, :decimal do
      public? true
      description "毛利 = sum(lines.margin)"
    end
    attribute :margin_percent, :decimal do
      public? true
      description "毛利率 = margin / amount_untaxed * 100"
    end
    attribute :order_date, :utc_datetime do
      allow_nil? false
      public? true
      description "下单时间"
    end
    attribute :notes, :string do
      public? true
      description "备注"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    has_many :items, UniboExPoc.POS.PosOrderLine do
      public? true
      source_attribute :refunded_order_id
      destination_attribute :order_id
    end
    has_many :payments, UniboExPoc.POS.PosPayment do
      public? true
      source_attribute :refunded_order_id
      destination_attribute :order_id
    end
    belongs_to :session, UniboExPoc.POS.PosSession do
      public? true
      allow_nil? false
    end
    belongs_to :partner, UniboExPoc.POS.Party do
      public? true
      source_attribute :partner_party_id
    end
    belongs_to :currency, UniboExPoc.POS.Currency do
      public? true
      allow_nil? false
    end
    belongs_to :fiscal_position, UniboExPoc.POS.FiscalPosition do
      public? true
    end
    belongs_to :table, UniboExPoc.POS.RestaurantTable do
      public? true
    end
    belongs_to :refunded_order, UniboExPoc.POS.PosOrder do
      public? true
    end
    has_many :refund_orders, UniboExPoc.POS.PosOrder do
      public? true
      source_attribute :refunded_order_id
      destination_attribute :refunded_order_id
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:order_number, :order_date, :discount_amount, :currency_id, :fiscal_position_id, :customer_count, :notes]
      argument :partner_id, :uuid
      argument :items, {:array, :string}, allow_nil?: false
      argument :session_id, :uuid, allow_nil?: false
      argument :table_id, :uuid
      change manage_relationship(:items, :items, type: :create)
      change manage_relationship(:session_id, :session, type: :append, on_lookup: :relate)
      argument :currency_id, :uuid, allow_nil?: false
      change manage_relationship(:currency_id, :currency, type: :append, on_lookup: :relate)
      validate present(:order_number)
      # validation: immutable_non_draft
      change UniboExPoc.POS.Changes.PosOrder.ComputeAmountTotal
      change UniboExPoc.POS.Changes.PosOrder.ComputeAmountUntaxed
      change set_attribute(:amount_tax, expr((amount_total - amount_untaxed)))
      change set_attribute(:id, expr(id))
    end
    update :pay do
      description "标记已付款，清理并重建 payment 记录，实时模式下触发库存拣货"
      primary? true
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
      change UniboExPoc.POS.Changes.PosOrder.PayCall4
      change UniboExPoc.POS.Changes.PosOrder.PayCall5
      change set_attribute(:status, :paid)
      change UniboExPoc.POS.Changes.PosOrder.PayCall7
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :done do
      description "标记订单完成（会话关闭时批量处理）"
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
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :invoice do
      description "开具发票，生成 account.move"
      argument :partner_id, :uuid
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
      change UniboExPoc.POS.Changes.PosOrder.InvoiceCall9
      change UniboExPoc.POS.Changes.PosOrder.InvoiceCall10
      change set_attribute(:status, :invoiced)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    create :refund do
      description "创建退款单（数量/金额取反的镜像订单）"
      accept []
      argument :refund_lines, {:array, :string}
      argument :items, {:array, :map}, default: []
      change manage_relationship(:items, :items, type: :create)
      argument :session_id, :uuid, allow_nil?: false
      change manage_relationship(:session_id, :session, type: :append, on_lookup: :relate)
      argument :currency_id, :uuid, allow_nil?: false
      change manage_relationship(:currency_id, :currency, type: :append, on_lookup: :relate)
      validate present(:order_number)
      # validation: immutable_non_draft
      change UniboExPoc.POS.Changes.PosOrder.ComputeAmountTotal
      change UniboExPoc.POS.Changes.PosOrder.ComputeAmountUntaxed
      change set_attribute(:amount_tax, expr((amount_total - amount_untaxed)))
      change UniboExPoc.POS.Changes.PosOrder.RefundCall12
      change UniboExPoc.POS.Changes.PosOrder.RefundCall13
      change set_attribute(:id, expr(id))
    end
    update :cancel do
      description "取消订单"
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
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    destroy :destroy do
      description "删除订单（仅 draft 或 cancel 状态）"
      validate attribute_in(:status, [:draft, :cancel])
      # message: "仅草稿或取消状态可删除"
      change set_attribute(:id, expr(id))
    end
  end

  identities do
    identity :unique_order_number, [:order_number]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
    archive_related [:items, :payments, :refund_orders]
  end

end
