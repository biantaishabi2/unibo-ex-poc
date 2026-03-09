# Workflow: supplier_lifecycle — 供应商生命周期（创建→运营→归档）
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> send_orders
#   create --> archive
#   update --> update
#   update --> send_orders
#   update --> archive
#   send_orders --> confirm_orders
#   send_orders --> send_orders
#   confirm_orders --> send_orders
#   confirm_orders --> archive
#   archive --> unarchive
#   unarchive --> update
#   unarchive --> send_orders
#   unarchive --> archive
# ```
defmodule UniboExPoc.Lunch.LunchSupplier do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Lunch,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource],
    notifiers: [UniboExPoc.Lunch.LunchSupplier.Notifier]

  resource do
    description "午餐供应商，管理营业时间、配送方式、配料分类定义"
  end

  postgres do
    table "lunch_suppliers"
    repo UniboExPoc.Repo
  end

  graphql do
    type :lunch_lunch_supplier

    queries do
      get :get_lunch_lunch_supplier, :read
      list :list_lunch_lunch_suppliers, :read
    end

    mutations do
      create :create_lunch_lunch_supplier, :create
      update :update_lunch_lunch_supplier, :update
      update :send_orders_lunch_lunch_supplier, :send_orders
      update :confirm_orders_lunch_lunch_supplier, :confirm_orders
      update :archive_lunch_lunch_supplier, :archive
      update :unarchive_lunch_lunch_supplier, :unarchive
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
      description "供应商名称（来自关联partner）"
    end
    attribute :send_by, :atom do
      allow_nil? false
      constraints one_of: [:phone, :email]
      public? true
      description "订单发送方式"
    end
    attribute :automatic_email_time, :float do
      public? true
      description "自动邮件发送时间（0-12，小时制）"
    end
    attribute :moment, :atom do
      constraints one_of: [:am, :pm]
      public? true
      description "上午/下午标识"
    end
    attribute :tz, :string do
      public? true
      description "时区（用于定时任务计算）"
    end
    attribute :mon, :boolean do
      default false
      public? true
      description "周一营业"
    end
    attribute :tue, :boolean do
      default false
      public? true
      description "周二营业"
    end
    attribute :wed, :boolean do
      default false
      public? true
      description "周三营业"
    end
    attribute :thu, :boolean do
      default false
      public? true
      description "周四营业"
    end
    attribute :fri, :boolean do
      default false
      public? true
      description "周五营业"
    end
    attribute :sat, :boolean do
      default false
      public? true
      description "周六营业"
    end
    attribute :sun, :boolean do
      default false
      public? true
      description "周日营业"
    end
    attribute :recurrency_end_date, :date do
      public? true
      description "可用性截止日期"
    end
    attribute :topping_label_1, :string do
      public? true
      description "第1类配料分类标签"
    end
    attribute :topping_quantity_1, :atom do
      constraints one_of: [:none_or_more, :one_or_more, :only_one]
      default :none_or_more
      public? true
      description "第1类配料数量约束"
    end
    attribute :topping_label_2, :string do
      public? true
      description "第2类配料分类标签"
    end
    attribute :topping_quantity_2, :atom do
      constraints one_of: [:none_or_more, :one_or_more, :only_one]
      default :none_or_more
      public? true
      description "第2类配料数量约束"
    end
    attribute :topping_label_3, :string do
      public? true
      description "第3类配料分类标签"
    end
    attribute :topping_quantity_3, :atom do
      constraints one_of: [:none_or_more, :one_or_more, :only_one]
      default :none_or_more
      public? true
      description "第3类配料数量约束"
    end
    attribute :active, :boolean do
      default true
      public? true
      description "是否启用"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  calculations do
    calculate :available_today, :boolean, expr(available_on_date(today()))
    calculate :order_deadline_passed, :boolean, expr(deadline_passed(automatic_email_time, moment, tz))
    calculate :show_order_button, :boolean, {UniboExPoc.Lunch.Calculations.LunchSupplier.ShowOrderButton, []}
    calculate :show_confirm_button, :boolean, {UniboExPoc.Lunch.Calculations.LunchSupplier.ShowConfirmButton, []}
  end

  relationships do
    belongs_to :partner, UniboExPoc.Lunch.Party do
      public? true
      allow_nil? false
      source_attribute :partner_party_id
    end
    belongs_to :responsible, UniboExPoc.Lunch.Party do
      public? true
      source_attribute :responsible_party_id
    end
    has_many :products, UniboExPoc.Lunch.LunchProduct do
      public? true
      destination_attribute :supplier_id
    end
    has_many :toppings, UniboExPoc.Lunch.LunchTopping do
      public? true
      destination_attribute :supplier_id
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:name, :send_by, :automatic_email_time, :moment, :tz, :mon, :tue, :wed, :thu, :fri, :sat, :sun, :recurrency_end_date, :topping_label_1, :topping_quantity_1, :topping_label_2, :topping_quantity_2, :topping_label_3, :topping_quantity_3]
      argument :partner_id, :uuid, allow_nil?: false
      change manage_relationship(:partner_id, :partner, type: :append, on_lookup: :relate)
      validate present(:name)
      validate present(:send_by)
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:name, :send_by, :automatic_email_time, :moment, :tz, :mon, :tue, :wed, :thu, :fri, :sat, :sun, :recurrency_end_date, :topping_label_1, :topping_quantity_1, :topping_label_2, :topping_quantity_2, :topping_label_3, :topping_quantity_3]
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :send_orders do
      description "批量发送当日订单给供应商（邮件方式调用自动邮件；电话方式逐条标记sent）"
      accept []
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :confirm_orders do
      description "批量确认当日所有sent状态订单"
      accept []
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :archive do
      description "归档供应商（级联归档所有关联产品）"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :active)
        if current == true do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :active, message: "must equal %{value}", vars: %{value: true}))
        end
      end
      # message: "只有启用状态的供应商可以归档"
      change set_attribute(:active, false)
      change set_attribute(:active, false)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :unarchive do
      description "取消归档供应商"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :active)
        if current == false do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :active, message: "must equal %{value}", vars: %{value: false}))
        end
      end
      # message: "只有已归档状态的供应商可以取消归档"
      change set_attribute(:active, true)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
