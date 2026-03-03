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
defmodule UniboV4.Repair.RepairTicket do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Repair,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource],
    notifiers: [UniboV4.Repair.RepairTicket.Notifier]

  postgres do
    table "repair_tickets"
    repo UniboV4.Repo
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
    end
    attribute :state, :atom do
      allow_nil? false
      constraints one_of: [:draft, :confirmed, :under_repair, :repaired, :done, :cancelled]
      default :draft
      public? true
    end
    attribute :description, :string, public?: true
    attribute :internal_notes, :string, public?: true
    attribute :warranty_applicable, :boolean do
      default false
      public? true
    end
    attribute :warranty_expiry_date, :date, public?: true
    attribute :scheduled_date, :utc_datetime, public?: true
    attribute :completion_date, :utc_datetime, public?: true
    attribute :currency_id, :string, public?: true
    attribute :total_fee, :decimal, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :repair_lines, UniboV4.Repair.RepairLine do
      public? true
      destination_attribute :repair_ticket_id
    end
    has_many :repair_fees, UniboV4.Repair.RepairFee do
      public? true
      destination_attribute :repair_ticket_id
    end
    has_many :tags, UniboV4.Repair.RepairTag do
      public? true
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
      validate present(:repair_number)
      validate present(:customer_id)
      validate present(:product_id)
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
      accept [:description, :internal_notes, :warranty_applicable, :warranty_expiry_date, :scheduled_date]
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
    update :confirm do
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
    update :start_repair do
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
    update :complete_repair do
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
    update :deliver do
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
    update :cancel do
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
    # TODO: 不支持的校验规则 unique
  end

  identities do
    identity :unique_repair_number, [:repair_number]
  end

end
