# Workflow: iot_device_sync_flow — 设备发现上报、配置更新与读数同步流程
# ```mermaid
# stateDiagram-v2
#   [*] --> upsert
#   upsert --> [*]
#   update --> [*]
#   update_value --> [*]
# ```
defmodule UniboV4.IoT.IoTDevice do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.IoT,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "io_t_devices"
    repo UniboV4.Repo
  end

  graphql do
    type :io_t_io_t_device

    queries do
      get :get_io_t_io_t_device, :read
      list :list_io_t_io_t_devices, :read
    end

    mutations do
      create :create_upsert_io_t_io_t_device, :upsert
      update :update_io_t_io_t_device, :update
      update :update_value_io_t_io_t_device, :update_value
    end

  end

  attributes do
    attribute :id, :integer do
      primary_key? true
      allow_nil? false
      public? true
    end
    attribute :name, :string do
      allow_nil? false
      default "auto_gen"
      public? true
    end
    attribute :identifier, :string do
      allow_nil? false
      public? true
    end
    attribute :device_type, :atom do
      allow_nil? false
      constraints one_of: [:printer, :scale, :camera, :scanner, :sensor, :display, :payment_terminal]
      public? true
    end
    attribute :connection, :atom do
      allow_nil? false
      constraints one_of: [:usb, :bluetooth, :wifi, :hdmi, :network]
      public? true
    end
    attribute :status, :atom do
      allow_nil? false
      constraints one_of: [:connected, :disconnected, :error]
      default :disconnected
      public? true
    end
    attribute :driver_name, :string, public?: true
    attribute :capabilities, :string, public?: true
    attribute :configuration, :string, public?: true
    attribute :last_value, :string, public?: true
    attribute :last_event_at, :utc_datetime, public?: true
    attribute :health_status, :atom do
      constraints one_of: [:ok, :warning, :error]
      default :ok
      public? true
    end
    attribute :health_message, :string, public?: true
    attribute :manufacturer, :string, public?: true
    attribute :model, :string, public?: true
  end

  calculations do
    # TODO: 不支持的 calculation 表达式 :is_online
    # TODO: 不支持的 calculation 表达式 :time_since_last_event
  end

  relationships do
    belongs_to :iot_box, UniboV4.IoT.IoTBox do
      public? true
      allow_nil? false
      attribute_type :integer
    end
    has_many :trigger_rules, UniboV4.IoT.TriggerRule do
      public? true
      destination_attribute :device_id
    end
    has_many :event_logs, UniboV4.IoT.EventLog do
      public? true
      destination_attribute :device_id
    end
  end

  actions do
    defaults [:read]
    create :upsert do
      primary? true
      accept [:name, :identifier, :device_type, :connection, :driver_name, :capabilities, :configuration, :manufacturer, :model]
      argument :iot_box_id, :uuid, allow_nil?: false
      change manage_relationship(:iot_box_id, :iot_box, type: :append, on_lookup: :relate)
      validate present(:identifier)
      validate present(:iot_box_id)
      # TODO: 不支持的表达式类型
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
      accept [:name, :driver_name, :capabilities, :configuration]
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
    update :update_value do
      accept [:last_value]
      change set_attribute(:last_event_at, &DateTime.utc_now/0)
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
    identity :unique_device_per_box, [:iot_box_id, :identifier]
  end

end
