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
    otp_app: :unibo_v4,
    domain: UniboV4.Subscriptions,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource],
    notifiers: [UniboV4.Subscriptions.SubscriptionOrder.Notifier]

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
    end
    attribute :subscription_state, :atom do
      allow_nil? false
      constraints one_of: [:draft, :in_progress, :paused, :closed]
      default :draft
      public? true
    end
    attribute :start_date, :date do
      allow_nil? false
      public? true
    end
    attribute :end_date, :date, public?: true
    attribute :next_invoice_date, :date do
      allow_nil? false
      public? true
    end
    attribute :close_date, :date, public?: true
    attribute :payment_exception, :boolean do
      allow_nil? false
      default false
      public? true
    end
    attribute :first_payment_failure_date, :date, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  calculations do
    calculate :recurring_total, :decimal, expr(sum(lines, field: :price_subtotal, query: [filter: expr(true)]))
    # TODO: 不支持的 calculation 表达式 :mrr
    # TODO: 不支持的 calculation 表达式 :arr
    calculate :amount_untaxed, :decimal, expr(sum(lines, field: :price_subtotal, query: [filter: expr(true)]))
    # TODO: 不支持的 calculation 表达式 :amount_tax
    # TODO: 不支持的 calculation 表达式 :amount_total
    # TODO: 不支持的 calculation 表达式 :health
  end

  relationships do
    has_many :lines, UniboV4.Subscriptions.SubscriptionOrderLine do
      public? true
      destination_attribute :order_id
    end
    has_many :logs, UniboV4.Subscriptions.SubscriptionLog do
      public? true
      destination_attribute :subscription_id
    end
    belongs_to :recurring_plan, UniboV4.Subscriptions.SubscriptionPlan do
      public? true
      allow_nil? false
    end
    belongs_to :close_reason, UniboV4.Subscriptions.CloseReason do
      public? true
    end
    belongs_to :partner, UniboV4.Subscriptions.Partner do
      public? true
      allow_nil? false
    end
    belongs_to :salesperson, UniboV4.Subscriptions.User do
      public? true
      allow_nil? false
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
      accept [:end_date, :next_invoice_date]
      argument :payment_token_id, :uuid
      argument :pricelist_id, :uuid
      argument :team_id, :uuid
      argument :stage_id, :uuid
      argument :lines, {:array, :map}, default: []
      change manage_relationship(:lines, :lines, on_lookup: :relate, on_no_match: :create, on_match: :update)
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
        current = Ash.Changeset.get_attribute(changeset, :subscription_state)
        if current == :draft do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :subscription_state, message: "must equal %{value}", vars: %{value: :draft}))
        end
      end
      # message: "只有草稿状态可以确认"
      change set_attribute(:subscription_state, :in_progress)
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
    update :action_pause do
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
    update :action_resume do
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
    update :action_close do
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
      # TODO: 跨实体聚合表达式暂不支持
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
    create :action_renew do
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
      validate attribute_equals(:subscription_state, :closed)
      # message: "只有已关闭状态可以续订"
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
    end
    update :action_upsell do
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
    update :mark_payment_exception do
      accept []
      change set_attribute(:payment_exception, true)
      # TODO: 跨实体聚合表达式暂不支持
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
    update :clear_payment_exception do
      accept []
      change set_attribute(:payment_exception, false)
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

  identities do
    identity :unique_subscription_name, [:name]
  end

end
