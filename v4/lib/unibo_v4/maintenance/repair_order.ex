defmodule UniboV4.Maintenance.RepairOrder do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Maintenance,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource],
    notifiers: [UniboV4.Maintenance.RepairOrder.Notifier]

  postgres do
    table "repair_orders"
    repo UniboV4.Repo
  end

  graphql do
    type :repair_order

    queries do
      get :get_repair_order, :read
      list :list_repair_orders, :read
    end

    mutations do
      create :create_repair_order, :create
      update :confirm_repair_order, :confirm
      update :start_repair_repair_order, :start_repair
      update :complete_repair_repair_order, :complete_repair
      update :cancel_repair_order, :cancel
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :repair_number, :string, allow_nil?: false
    attribute :status, :atom do
      constraints one_of: [:draft, :confirmed, :in_repair, :repaired, :cancelled]
      default :draft
    end
    attribute :diagnosis, :string
    attribute :repair_notes, :string
    attribute :estimated_cost, :decimal
    attribute :actual_cost, :decimal
    attribute :repair_date, :date
    attribute :completion_date, :date
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :equipment, UniboV4.Maintenance.Equipment do
      allow_nil? false
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:repair_number, :diagnosis, :repair_notes, :estimated_cost, :repair_date]
      argument :equipment_id, :uuid, allow_nil?: false
      change manage_relationship(:equipment_id, :equipment, type: :append, on_lookup: :relate)
      validate present(:repair_number)
    end
    update :confirm do
      accept []
      validate attribute_equals(:status, :draft) do
        message "只有草稿状态可以确认"
      end
      change set_attribute(:status, :confirmed)
    end
    update :start_repair do
      accept []
      validate attribute_equals(:status, :confirmed) do
        message "只有已确认状态可以开始维修"
      end
      change set_attribute(:status, :in_repair)
    end
    update :complete_repair do
      accept [:actual_cost]
      validate attribute_equals(:status, :in_repair) do
        message "只有维修中状态可以完成"
      end
      change set_attribute(:status, :repaired)
    end
    update :cancel do
      accept []
      validate attribute_in(:status, [:draft, :confirmed]) do
        message "只有草稿或已确认状态可以取消"
      end
      change set_attribute(:status, :cancelled)
    end
  end

  identities do
    identity :unique_repair_number, [:repair_number]
  end

end
