# Workflow: repair_ticket_lifecycle — 维修工单完整生命周期
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> confirm
#   create --> cancel
#   confirm --> start_repair
#   confirm --> cancel
#   start_repair --> complete_repair
#   complete_repair --> deliver
#   deliver --> [*] : delivered
#   cancel --> [*] : cancelled
# ```
defmodule UniboExPoc.Repair.RepairTicket do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Repair,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource],
    notifiers: [UniboExPoc.Repair.RepairTicket.Notifier]

  resource do
    description "维修工单，客户送修产品的主工单，追踪从接单到交付的全生命周期"
  end

  postgres do
    table "repair_tickets"
    repo UniboExPoc.Repo
  end

  graphql do
    type :repair_repair_ticket

    queries do
      get :get_repair_repair_ticket, :read
      list :list_repair_repair_tickets, :read
    end

    mutations do
      create :create_repair_repair_ticket, :create
      update :update_repair_repair_ticket, :update
      update :confirm_repair_repair_ticket, :confirm
      update :start_repair_repair_repair_ticket, :start_repair
      update :complete_repair_repair_repair_ticket, :complete_repair
      update :deliver_repair_repair_ticket, :deliver
      update :cancel_repair_repair_ticket, :cancel
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :repair_number, :string do
      allow_nil? false
      public? true
      description "工单编号，格式 RO-YYYYMMDD-NNNN"
    end
    attribute :state, :atom do
      allow_nil? false
      constraints one_of: [:draft, :confirmed, :under_repair, :repaired, :done, :cancelled]
      default :draft
      public? true
      description "工单状态（草稿/已确认/维修中/已完成维修/已交付/已取消）"
    end
    attribute :description, :string do
      public? true
      description "故障描述/客户备注"
    end
    attribute :internal_notes, :string do
      public? true
      description "内部备注（仅技术员可见）"
    end
    attribute :warranty_applicable, :boolean do
      default false
      public? true
      description "是否适用保修"
    end
    attribute :warranty_expiry_date, :date do
      public? true
      description "保修到期日，由关联 Warranty 记录或手动录入"
    end
    attribute :scheduled_date, :utc_datetime do
      public? true
      description "预约维修日期"
    end
    attribute :completion_date, :utc_datetime do
      public? true
      description "实际完成日期"
    end
    attribute :currency_id, :string do
      public? true
      description "结算币种（对应 OFBiz currency_uom_id）"
    end
    attribute :total_fee, :decimal do
      public? true
      description "费用合计（零件费 + 工时费 + 调整费）"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :customer, UniboExPoc.Repair.Party do
      public? true
      allow_nil? false
      source_attribute :customer_party_id
    end
    belongs_to :technician, UniboExPoc.Repair.Party do
      public? true
      source_attribute :technician_party_id
    end
    has_many :repair_lines, UniboExPoc.Repair.RepairLine do
      public? true
      destination_attribute :repair_ticket_id
    end
    has_many :repair_fees, UniboExPoc.Repair.RepairFee do
      public? true
      destination_attribute :repair_ticket_id
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:repair_number, :description, :internal_notes, :warranty_applicable, :warranty_expiry_date, :scheduled_date, :currency_id]
      argument :customer_id, :uuid, allow_nil?: false
      argument :product_id, :uuid, allow_nil?: false
      argument :sales_order_id, :uuid
      argument :facility_id, :uuid
      argument :technician_id, :uuid
      change manage_relationship(:customer_id, :customer, type: :append, on_lookup: :relate)
      validate present(:repair_number)
      validate present(:customer_id)
      validate present(:product_id)
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:description, :internal_notes, :warranty_applicable, :warranty_expiry_date, :scheduled_date]
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :confirm do
      description "确认工单（draft -> confirmed）"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :state)
        if current == :draft do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :state, message: "must equal %{value}", vars: %{value: :draft}))
        end
      end
      # message: "只有草稿状态可以确认"
      change set_attribute(:state, :confirmed)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :start_repair do
      description "开始维修（confirmed -> under_repair）"
      argument :technician_id, :uuid
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :state)
        if current == :confirmed do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :state, message: "must equal %{value}", vars: %{value: :confirmed}))
        end
      end
      # message: "只有已确认工单可以开始维修"
      change set_attribute(:state, :under_repair)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :complete_repair do
      description "完成维修（under_repair -> repaired）"
      accept [:internal_notes]
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :state)
        if current == :under_repair do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :state, message: "must equal %{value}", vars: %{value: :under_repair}))
        end
      end
      # message: "只有维修中工单可以标记完成"
      change set_attribute(:state, :repaired)
      change set_attribute(:completion_date, &DateTime.utc_now/0)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :deliver do
      description "交付客户（repaired -> done）"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :state)
        if current == :repaired do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :state, message: "must equal %{value}", vars: %{value: :repaired}))
        end
      end
      # message: "只有已修复工单可以交付"
      change set_attribute(:state, :done)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :cancel do
      description "取消工单（draft/confirmed -> cancelled）"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :state)
        if current in [:draft, :confirmed] do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :state, message: "must be one of %{values}", vars: %{values: [:draft, :confirmed]}))
        end
      end
      # message: "只有草稿或确认状态可以取消"
      change set_attribute(:state, :cancelled)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  identities do
    identity :unique_repair_number, [:repair_number]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
