# Workflow: iot_box_lifecycle_flow — IoTBox 创建、配对注册、心跳更新与配置维护流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   register_box --> [*]
#   heartbeat --> [*]
#   update --> [*]
# ```
defmodule UniboExPoc.IoT.IoTBox do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.IoT,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource],
    notifiers: [UniboExPoc.IoT.IoTBox.Notifier]

  resource do
    description "IoT 网关盒子，负责连接和管理物理设备，通过心跳保持在线状态"
  end

  postgres do
    table "io_t_boxes"
    repo UniboExPoc.Repo
  end

  graphql do
    type :io_t_io_t_box

    queries do
      get :get_io_t_io_t_box, :read
      list :list_io_t_io_t_boxs, :read
    end

    mutations do
      create :create_io_t_io_t_box, :create
      update :update_io_t_io_t_box, :update
      update :register_box_io_t_io_t_box, :register_box
      update :heartbeat_io_t_io_t_box, :heartbeat
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
      public? true
      description "显示名称"
    end
    attribute :ip_address, :string do
      public? true
      description "IP 地址"
    end
    attribute :identifier, :string do
      allow_nil? false
      public? true
      description "唯一标识令牌"
    end
    attribute :pairing_token, :string do
      default "random_8_char"
      public? true
      description "一次性配对令牌，配对成功后置 nil"
    end
    attribute :firmware_version, :string do
      public? true
      description "固件版本号"
    end
    attribute :connection_type, :atom do
      allow_nil? false
      constraints one_of: [:ethernet, :wifi, :cellular]
      default :ethernet
      public? true
      description "网络连接方式"
    end
    attribute :status, :atom do
      allow_nil? false
      constraints one_of: [:pending, :online, :offline, :error]
      default :pending
      public? true
      description "网关状态"
    end
    attribute :last_heartbeat_at, :utc_datetime do
      public? true
      description "最后心跳时间戳"
    end
    attribute :last_seen_at, :utc_datetime do
      public? true
      description "最后可见时间"
    end
    attribute :auto_update, :boolean do
      default true
      public? true
      description "是否自动更新固件"
    end
    attribute :network_info, :string do
      public? true
      description "网络详情 {mac, ssid, gateway, dns, signal_strength}"
    end
    attribute :paired_at, :utc_datetime do
      public? true
      description "配对成功时间"
    end
  end

  calculations do
    calculate :device_count, :integer, expr(count(devices, query: [filter: expr(true)]))
    calculate :is_stale, :boolean, expr(datetime_diff("now", last_heartbeat_at) > 300)
  end

  relationships do
    has_many :devices, UniboExPoc.IoT.IoTDevice do
      public? true
      destination_attribute :iot_box_id
    end
    belongs_to :paired_by, UniboExPoc.IoT.Party do
      public? true
      source_attribute :paired_by_party_id
    end
    belongs_to :org, UniboExPoc.IoT.Org do
      public? true
      attribute_type :integer
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:name, :ip_address, :identifier, :firmware_version, :connection_type, :auto_update, :network_info, :org_id]
      validate present(:name)
      validate present(:identifier)
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:name, :ip_address, :firmware_version, :connection_type, :auto_update, :network_info]
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :register_box do
      description "通过配对令牌完成配对"
      argument :pairing_token, :string, allow_nil?: false
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :pending do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :pending}))
        end
      end
      # message: "只有待配对状态可以注册"
      change set_attribute(:status, :online)
      change set_attribute(:paired_at, &DateTime.utc_now/0)
      change relate_actor(:paired_by)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :heartbeat do
      description "接收心跳更新"
      accept [:ip_address, :firmware_version, :network_info]
      change set_attribute(:last_heartbeat_at, &DateTime.utc_now/0)
      change set_attribute(:last_seen_at, &DateTime.utc_now/0)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  identities do
    identity :unique_identifier, [:identifier]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
