# Workflow: subscription_lifecycle — 订阅全生命周期流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> action_confirm
#   action_confirm --> action_pause
#   action_confirm --> action_close
#   action_confirm --> action_upsell
#   action_pause --> action_resume
#   action_resume --> action_pause
#   action_resume --> action_close
#   action_resume --> action_upsell
#   action_close --> action_renew
#   action_renew --> [*] : renewed
# ```
# Workflow: cron_invoicing — 定时开票流程
# ```mermaid
# stateDiagram-v2
#   [*] --> evaluate_invoicing_due
#   evaluate_invoicing_due --> generate_invoice
#   generate_invoice --> [*]
# ```
# Workflow: cron_auto_close — 支付失败自动关闭流程
# ```mermaid
# stateDiagram-v2
#   [*] --> evaluate_auto_close_due
#   evaluate_auto_close_due --> action_close
#   action_close --> [*]
# ```
# Workflow: cron_expiry_close — 到期自动关闭流程
# ```mermaid
# stateDiagram-v2
#   [*] --> evaluate_expiry_due
#   evaluate_expiry_due --> action_close
#   action_close --> [*]
# ```
# Workflow: cron_payment_retry — 支付失败重试流程（每3天重试一次）
# ```mermaid
# stateDiagram-v2
#   [*] --> evaluate_retry_due
#   evaluate_retry_due --> retry_payment
#   retry_payment --> [*]
# ```
defmodule UniboV4.Subscriptions.SubscriptionOrder do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Subscriptions,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource],
    notifiers: [UniboV4.Subscriptions.SubscriptionOrder.Notifier]

  resource do
    description "订阅订单，承载客户订阅全生命周期"
  end

  postgres do
    table "subscriptions_subscription_orders"
    repo UniboV4.Repo
  end

  graphql do
    type :subscriptions_subscription_order

    queries do
      get :get_subscriptions_subscription_order, :read
      list :list_subscriptions_subscription_orders, :read
    end

    mutations do
      create :create_create_subscriptions_subscription_order, :create
      create :create_action_renew_subscriptions_subscription_order, :action_renew
      update :update_subscriptions_subscription_order, :update
      update :action_confirm_subscriptions_subscription_order, :action_confirm
      update :action_pause_subscriptions_subscription_order, :action_pause
      update :action_resume_subscriptions_subscription_order, :action_resume
      update :action_close_subscriptions_subscription_order, :action_close
      update :action_upsell_subscriptions_subscription_order, :action_upsell
      update :mark_payment_exception_subscriptions_subscription_order, :mark_payment_exception
      update :clear_payment_exception_subscriptions_subscription_order, :clear_payment_exception
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
      description "订阅编号，如 SUB-00042"
    end
    attribute :subscription_state, :atom do
      allow_nil? false
      constraints one_of: [:draft, :in_progress, :paused, :closed]
      default :draft
      public? true
      description "订阅状态"
    end
    attribute :start_date, :date do
      allow_nil? false
      public? true
      description "订阅开始日期"
    end
    attribute :end_date, :date do
      public? true
      description "结束日期，null 表示永续"
    end
    attribute :next_invoice_date, :date do
      allow_nil? false
      public? true
      description "下次开票日期，cron 读取"
    end
    attribute :close_date, :date do
      public? true
      description "实际关闭日期"
    end
    attribute :payment_exception, :boolean do
      allow_nil? false
      default false
      public? true
      description "是否存在支付异常"
    end
    attribute :first_payment_failure_date, :date do
      public? true
      description "首次支付失败日期"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  calculations do
    calculate :recurring_total, :decimal, expr(sum(lines, field: :price_subtotal, query: [filter: expr(true)]))
    calculate :mrr, :decimal, expr(%{condition: %{op: "eq", args: [%{op: "ref", args: ["subscription_state"]}, "closed"]}, result: 0})
    calculate :arr, :decimal, expr((mrr * 12))
    calculate :amount_untaxed, :decimal, expr(sum(lines, field: :price_subtotal, query: [filter: expr(true)]))
    calculate :amount_tax, :decimal, expr(sum_tax(lines))
    calculate :amount_total, :decimal, expr((amount_untaxed + amount_tax))
    calculate :health, :atom, expr(%{condition: %{op: "or", args: [%{op: "eq", args: [%{op: "ref", args: ["payment_exception"]}, true]}, %{op: "ref", args: ["mrr_declining_trend"]}]}, result: "bad"})
  end

  relationships do
    has_many :lines, UniboV4.Subscriptions.SubscriptionOrderLine do
      public? true
      source_attribute :origin_order_id
      destination_attribute :order_id
    end
    has_many :logs, UniboV4.Subscriptions.SubscriptionLog do
      public? true
      source_attribute :origin_order_id
      destination_attribute :subscription_id
    end
    belongs_to :recurring_plan, UniboV4.Subscriptions.SubscriptionPlan do
      public? true
      allow_nil? false
    end
    belongs_to :close_reason, UniboV4.Subscriptions.CloseReason do
      public? true
    end
    belongs_to :partner, UniboV4.Subscriptions.Party do
      public? true
      allow_nil? false
      source_attribute :partner_party_id
    end
    belongs_to :salesperson, UniboV4.Subscriptions.Party do
      public? true
      allow_nil? false
      source_attribute :salesperson_party_id
    end
    belongs_to :team, UniboV4.Subscriptions.SalesTeam do
      public? true
    end
    belongs_to :origin_order, UniboV4.Subscriptions.SubscriptionOrder do
      public? true
    end
    belongs_to :payment_token, UniboV4.Subscriptions.PaymentToken do
      public? true
    end
    belongs_to :currency, UniboV4.Subscriptions.Currency do
      public? true
      allow_nil? false
    end
    belongs_to :pricelist, UniboV4.Subscriptions.Pricelist do
      public? true
    end
    belongs_to :stage, UniboV4.Subscriptions.Stage do
      public? true
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:name, :start_date, :end_date, :next_invoice_date]
      argument :lines, {:array, :string}, allow_nil?: false
      argument :recurring_plan_id, :uuid, allow_nil?: false
      argument :partner_id, :uuid, allow_nil?: false
      argument :salesperson_id, :uuid, allow_nil?: false
      argument :currency_id, :uuid, allow_nil?: false
      argument :payment_token_id, :uuid
      argument :pricelist_id, :uuid
      argument :team_id, :uuid
      argument :stage_id, :uuid
      change manage_relationship(:lines, :lines, type: :create)
      change manage_relationship(:recurring_plan_id, :recurring_plan, type: :append, on_lookup: :relate)
      change manage_relationship(:partner_id, :partner, type: :append, on_lookup: :relate)
      change manage_relationship(:salesperson_id, :salesperson, type: :append, on_lookup: :relate)
      change manage_relationship(:currency_id, :currency, type: :append, on_lookup: :relate)
      validate present(:name)
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:end_date, :next_invoice_date, :payment_token_id, :pricelist_id, :team_id, :stage_id]
      argument :lines, {:array, :map}, default: []
      change manage_relationship(:lines, :lines, on_lookup: :relate, on_no_match: :create, on_match: :update)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :action_confirm do
      description "确认订阅（draft -> in_progress），生成首张发票"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :subscription_state)
        if current == :draft do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :subscription_state, message: "must equal %{value}", vars: %{value: :draft}))
        end
      end
      # message: "只有草稿状态可以确认"
      change set_attribute(:subscription_state, :in_progress)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :action_pause do
      description "暂停订阅（in_progress -> paused）"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :subscription_state)
        if current == :in_progress do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :subscription_state, message: "must equal %{value}", vars: %{value: :in_progress}))
        end
      end
      # message: "只有进行中状态可以暂停"
      change set_attribute(:subscription_state, :paused)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :action_resume do
      description "恢复订阅（paused -> in_progress）"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :subscription_state)
        if current == :paused do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :subscription_state, message: "must equal %{value}", vars: %{value: :paused}))
        end
      end
      # message: "只有暂停状态可以恢复"
      change set_attribute(:subscription_state, :in_progress)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :action_close do
      description "手动关闭订阅（in_progress -> closed）"
      argument :close_reason_id, :uuid, allow_nil?: false
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :subscription_state)
        if current == :in_progress do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :subscription_state, message: "must equal %{value}", vars: %{value: :in_progress}))
        end
      end
      # message: "只有进行中状态可以关闭"
      change set_attribute(:subscription_state, :closed)
      change UniboV4.Subscriptions.Changes.SubscriptionOrder.ComputeCloseDate
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    create :action_renew do
      description "续订（从已关闭订阅创建新的草稿订单）"
      accept []
      argument :lines, {:array, :map}, default: []
      change manage_relationship(:lines, :lines, type: :create)
      argument :recurring_plan_id, :uuid, allow_nil?: false
      change manage_relationship(:recurring_plan_id, :recurring_plan, type: :append, on_lookup: :relate)
      argument :partner_id, :uuid, allow_nil?: false
      change manage_relationship(:partner_id, :partner, type: :append, on_lookup: :relate)
      argument :salesperson_id, :uuid, allow_nil?: false
      change manage_relationship(:salesperson_id, :salesperson, type: :append, on_lookup: :relate)
      argument :currency_id, :uuid, allow_nil?: false
      change manage_relationship(:currency_id, :currency, type: :append, on_lookup: :relate)
      validate present(:name)
      # precondition: requires subscription_state=:closed
      validate attribute_equals(:subscription_state, :closed)
      change set_attribute(:id, expr(id))
    end
    update :action_upsell do
      description "升级/加购，生成差价报价单"
      argument :new_lines, {:array, :string}, allow_nil?: false
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :subscription_state)
        if current == :in_progress do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :subscription_state, message: "must equal %{value}", vars: %{value: :in_progress}))
        end
      end
      # message: "只有进行中状态可以升级"
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :mark_payment_exception do
      description "标记支付异常"
      accept []
      change set_attribute(:payment_exception, true)
      change UniboV4.Subscriptions.Changes.SubscriptionOrder.ComputeFirstPaymentFailureDate
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :clear_payment_exception do
      description "清除支付异常（重试扣款成功后）"
      accept []
      change set_attribute(:payment_exception, false)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  identities do
    identity :unique_subscription_name, [:name]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
