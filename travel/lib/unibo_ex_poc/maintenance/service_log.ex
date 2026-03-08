# Workflow: service_log_lifecycle — 服务记录生命周期
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> start
#   create --> cancel
#   start --> complete
#   start --> cancel
#   complete --> [*]
#   cancel --> [*]
# ```
defmodule UniboExPoc.Maintenance.ServiceLog do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Maintenance,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource]

  resource do
    description "车辆服务记录，3 态状态机，集成里程追加写入"
  end

  postgres do
    table "maintenance_service_logs"
    repo UniboExPoc.Repo
  end

  graphql do
    type :maintenance_service_log

    queries do
      get :get_maintenance_service_log, :read
      list :list_maintenance_service_logs, :read
    end

    mutations do
      create :create_maintenance_service_log, :create
      update :start_maintenance_service_log, :start
      update :complete_maintenance_service_log, :complete
      update :cancel_maintenance_service_log, :cancel
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :state, :atom do
      constraints one_of: [:new, :running, :done, :cancelled]
      default :new
      public? true
      description "状态机: new->running->done/cancelled"
    end
    attribute :amount, :decimal do
      public? true
      description "服务费用"
    end
    attribute :odometer_value, :float do
      public? true
      description "关联里程（通过 inverse 追加写入 Odometer）"
    end
    attribute :date, :date do
      default &Date.utc_today/0
      public? true
      description "服务日期"
    end
    attribute :invoice_ref, :string do
      public? true
      description "供应商发票参考号"
    end
    attribute :active, :boolean do
      default true
      public? true
    end
    attribute :notes, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :vehicle, UniboExPoc.Maintenance.Vehicle do
      public? true
      allow_nil? false
    end
    belongs_to :service_type, UniboExPoc.Maintenance.ServiceType do
      public? true
      allow_nil? false
    end
    belongs_to :vendor, UniboExPoc.Maintenance.Party do
      public? true
      source_attribute :vendor_party_id
    end
    belongs_to :purchaser, UniboExPoc.Maintenance.Party do
      public? true
      source_attribute :purchaser_party_id
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:amount, :odometer_value, :date, :invoice_ref, :notes]
      argument :vehicle_id, :uuid, allow_nil?: false
      argument :service_type_id, :uuid, allow_nil?: false
      change manage_relationship(:vehicle_id, :vehicle, type: :append, on_lookup: :relate)
      change manage_relationship(:service_type_id, :service_type, type: :append, on_lookup: :relate)
      change UniboExPoc.Maintenance.Changes.ServiceLog.CreateCall4
      change UniboExPoc.Maintenance.Changes.ServiceLog.CreateCall5
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
    end
    update :start do
      description "开始服务 (new -> running)"
      primary? true
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :state)
        if current == :new do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :state, message: "must equal %{value}", vars: %{value: :new}))
        end
      end
      # message: "只有新建状态可以开始"
      change set_attribute(:state, :running)
      change UniboExPoc.Maintenance.Changes.ServiceLog.StartCall5
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
    update :complete do
      description "完成服务 (running -> done)"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :state)
        if current == :running do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :state, message: "must equal %{value}", vars: %{value: :running}))
        end
      end
      # message: "只有进行中状态可以完成"
      change set_attribute(:state, :done)
      change UniboExPoc.Maintenance.Changes.ServiceLog.CompleteCall5
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
      description "取消服务 (new/running -> cancelled)"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :state)
        if current in [:new, :running] do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :state, message: "must be one of %{values}", vars: %{values: [:new, :running]}))
        end
      end
      # message: "只有新建或进行中状态可以取消"
      change set_attribute(:state, :cancelled)
      change UniboExPoc.Maintenance.Changes.ServiceLog.CancelCall5
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

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
