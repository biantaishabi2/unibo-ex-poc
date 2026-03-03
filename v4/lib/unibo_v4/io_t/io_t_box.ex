# Workflow: iot_box_lifecycle_flow — IoTBox 创建、配对注册、心跳更新与配置维护流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   register_box --> [*]
#   heartbeat --> [*]
#   update --> [*]
# ```
defmodule UniboV4.IoT.IoTBox do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.IoT,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource],
    notifiers: [UniboV4.IoT.IoTBox.Notifier]

  postgres do
    table "io_t_boxes"
    repo UniboV4.Repo
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
      public? true
    end
    attribute :name, :string do
      allow_nil? false
      public? true
    end
    attribute :ip_address, :string, public?: true
    attribute :identifier, :string do
      allow_nil? false
      public? true
    end
    attribute :pairing_token, :string do
      default "random_8_char"
      public? true
    end
    attribute :firmware_version, :string, public?: true
    attribute :connection_type, :atom do
      allow_nil? false
      constraints one_of: [:ethernet, :wifi, :cellular]
      default :ethernet
      public? true
    end
    attribute :status, :atom do
      allow_nil? false
      constraints one_of: [:pending, :online, :offline, :error]
      default :pending
      public? true
    end
    attribute :last_heartbeat_at, :utc_datetime, public?: true
    attribute :last_seen_at, :utc_datetime, public?: true
    attribute :auto_update, :boolean do
      default true
      public? true
    end
    attribute :network_info, :string, public?: true
    attribute :paired_at, :utc_datetime, public?: true
  end

  calculations do
    calculate :device_count, :integer, expr(count(devices, query: [filter: expr(true)]))
    # TODO: 不支持的 calculation 表达式 :is_stale
  end

  relationships do
    has_many :devices, UniboV4.IoT.IoTDevice do
      public? true
      destination_attribute :iot_box_id
    end
    belongs_to :paired_by, UniboV4.IoT.User do
      public? true
      source_attribute :paired_by_user_id
      attribute_type :integer
    end
    belongs_to :org, UniboV4.IoT.Org do
      public? true
      attribute_type :integer
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:name, :ip_address, :identifier, :firmware_version, :connection_type, :auto_update, :network_info]
      validate present(:name)
      validate present(:identifier)
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
      accept [:name, :ip_address, :firmware_version, :connection_type, :auto_update, :network_info]
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
    update :register_box do
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
    update :heartbeat do
      accept [:ip_address, :firmware_version, :network_info]
      change set_attribute(:last_heartbeat_at, &DateTime.utc_now/0)
      change set_attribute(:last_seen_at, &DateTime.utc_now/0)
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
    identity :unique_identifier, [:identifier]
  end

end
