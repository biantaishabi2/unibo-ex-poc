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
    otp_app: :unibo_ex_poc,
    domain: UniboV4.IoT,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource]

  resource do
    description "IoT 设备/外设，通过网关发现和管理，按 identifier+box_id 做 upsert"
  end

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
      generated? true
      public? true
    end
    attribute :name, :string do
      allow_nil? false
      default "auto_gen"
      public? true
      description "设备名称"
    end
    attribute :identifier, :string do
      allow_nil? false
      public? true
      description "设备标识（唯一于 box 内）"
    end
    attribute :device_type, :atom do
      allow_nil? false
      constraints one_of: [:printer, :scale, :camera, :scanner, :sensor, :display, :payment_terminal]
      public? true
      description "设备类型"
    end
    attribute :connection, :atom do
      allow_nil? false
      constraints one_of: [:usb, :bluetooth, :wifi, :hdmi, :network]
      public? true
      description "连接方式"
    end
    attribute :status, :atom do
      allow_nil? false
      constraints one_of: [:connected, :disconnected, :error]
      default :disconnected
      public? true
      description "设备状态"
    end
    attribute :driver_name, :string do
      public? true
      description "驱动标识（如 \"epson_tm_t20\"）"
    end
    attribute :capabilities, :string do
      public? true
      description "能力列表，如 [\"print\", \"cut\", \"cash_drawer\"]"
    end
    attribute :configuration, :string do
      public? true
      description "设备专属配置（按类型不同结构不同）"
    end
    attribute :last_value, :string do
      public? true
      description "最新读数/状态"
    end
    attribute :last_event_at, :utc_datetime do
      public? true
      description "最后事件时间"
    end
    attribute :health_status, :atom do
      constraints one_of: [:ok, :warning, :error]
      default :ok
      public? true
      description "健康状态"
    end
    attribute :health_message, :string do
      public? true
      description "健康状态描述"
    end
    attribute :manufacturer, :string do
      public? true
      description "制造商"
    end
    attribute :model, :string do
      public? true
      description "型号"
    end
  end

  calculations do
    calculate :is_online, :boolean, {UniboV4.IoT.Calculations.IoTDevice.IsOnline, []}
    calculate :time_since_last_event, :integer, expr(datetime_diff("now", last_event_at))
  end

  relationships do
    belongs_to :iot_box, UniboV4.IoT.IoTBox do
      public? true
      allow_nil? false
      attribute_type :integer
    end
    has_many :trigger_rules, UniboV4.IoT.TriggerRule do
      public? true
      source_attribute :iot_box_id
      destination_attribute :device_id
    end
    has_many :event_logs, UniboV4.IoT.EventLog do
      public? true
      source_attribute :iot_box_id
      destination_attribute :device_id
    end
  end

  actions do
    defaults [:read]
    create :upsert do
      description "按 identifier+box_id 查找或创建设备"
      primary? true
      accept [:iot_box_id, :name, :identifier, :device_type, :connection, :driver_name, :capabilities, :configuration, :manufacturer, :model]
      argument :iot_box_id, :integer, allow_nil?: false
      change manage_relationship(:iot_box_id, :iot_box, type: :append, on_lookup: :relate)
      validate present(:identifier)
      validate present(:iot_box_id)
      change set_attribute(:name, expr(device_type <> "-" <> identifier))
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:name, :driver_name, :capabilities, :configuration]
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :update_value do
      description "更新设备最新读数"
      accept [:last_value]
      change set_attribute(:last_event_at, &DateTime.utc_now/0)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  identities do
    identity :unique_device_per_box, [:iot_box_id, :identifier]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
