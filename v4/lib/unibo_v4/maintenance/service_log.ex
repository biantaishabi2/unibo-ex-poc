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
defmodule UniboV4.Maintenance.ServiceLog do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Maintenance,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "maintenance_service_logs"
    repo UniboV4.Repo
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
    end
    attribute :amount, :decimal, public?: true
    attribute :odometer_value, :float, public?: true
    attribute :date, :date do
      default &Date.utc_today/0
      public? true
    end
    attribute :invoice_ref, :string, public?: true
    attribute :active, :boolean do
      default true
      public? true
    end
    attribute :notes, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :vehicle, UniboV4.Maintenance.Vehicle do
      public? true
      allow_nil? false
    end
    belongs_to :service_type, UniboV4.Maintenance.ServiceType do
      public? true
      allow_nil? false
    end
    belongs_to :vendor, UniboV4.Maintenance.Partner do
      public? true
    end
    belongs_to :purchaser, UniboV4.Maintenance.Partner do
      public? true
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
      # TODO: 不支持的 change effect append_odometer
      # TODO: 不支持的 change effect compute_purchaser
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
      # TODO: 不支持的 change effect compute_purchaser
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
      # TODO: 不支持的 change effect compute_purchaser
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
        if current in [:new, :running] do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :state, message: "must be one of %{values}", vars: %{values: [:new, :running]}))
        end
      end
      # message: "只有新建或进行中状态可以取消"
      change set_attribute(:state, :cancelled)
      # TODO: 不支持的 change effect compute_purchaser
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

end
