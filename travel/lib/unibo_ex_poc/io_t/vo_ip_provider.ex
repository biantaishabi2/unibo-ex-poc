# Workflow: voip_provider_lifecycle_flow — VoIP 服务商配置创建、更新与删除流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
#   destroy --> [*]
# ```
defmodule UniboExPoc.IoT.VoIPProvider do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.IoT,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "SIP 服务商配置，存储 SIP/STUN/TURN 连接参数及 WebSocket/编解码器配置，密码加密存储"
  end

  postgres do
    table "io_t_vo_ip_providers"
    repo UniboExPoc.Repo
  end

  graphql do
    type :io_t_vo_ip_provider

    queries do
      get :get_io_t_vo_ip_provider, :read
      list :list_io_t_vo_ip_providers, :read
    end

    mutations do
      create :create_io_t_vo_ip_provider, :create
      update :update_io_t_vo_ip_provider, :update
      destroy :delete_io_t_vo_ip_provider, :destroy
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
      description "显示名"
    end
    attribute :sip_server, :string do
      allow_nil? false
      public? true
      description "SIP 服务器地址"
    end
    attribute :sip_port, :integer do
      default 5060
      public? true
      description "端口（TLS 使用 5061）"
    end
    attribute :transport, :atom do
      allow_nil? false
      constraints one_of: [:udp, :tcp, :tls, :wss]
      default :wss
      public? true
      description "传输协议"
    end
    attribute :domain, :string do
      allow_nil? false
      public? true
      description "SIP domain"
    end
    attribute :outbound_proxy, :string do
      public? true
      description "出站代理地址"
    end
    attribute :stun_server, :string do
      public? true
      description "STUN 服务器（WebRTC NAT 穿透）"
    end
    attribute :turn_server, :string do
      public? true
      description "TURN 服务器（WebRTC relay）"
    end
    attribute :turn_username, :string do
      public? true
      description "TURN 用户名"
    end
    attribute :turn_password, :string do
      public? true
      description "TURN 密码（AES-256 加密存储）"
    end
    attribute :websocket_url, :string do
      public? true
      description "WebSocket 连接 URL（WebRTC 模式使用）"
    end
    attribute :codecs, :string do
      public? true
      description "支持的编解码器列表（逗号分隔，如 opus,g711a,g711u）"
    end
    attribute :is_default, :boolean do
      default false
      public? true
      description "是否默认服务商"
    end
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :org, UniboExPoc.IoT.Org do
      public? true
      allow_nil? false
      attribute_type :integer
    end
    has_many :calls, UniboExPoc.IoT.VoIPCall do
      public? true
      source_attribute :org_id
      destination_attribute :provider_id
    end
    has_many :user_configs, UniboExPoc.IoT.VoIPUserConfig do
      public? true
      source_attribute :org_id
      destination_attribute :provider_id
    end
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:name, :sip_server, :sip_port, :transport, :domain, :outbound_proxy, :stun_server, :turn_server, :turn_username, :turn_password, :websocket_url, :codecs, :is_default, :org_id]
      argument :org_id, :integer, allow_nil?: false
      change manage_relationship(:org_id, :org, type: :append, on_lookup: :relate)
      validate present(:name)
      validate present(:sip_server)
      validate present(:domain)
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:name, :sip_server, :sip_port, :transport, :domain, :outbound_proxy, :stun_server, :turn_server, :turn_username, :turn_password, :websocket_url, :codecs, :is_default]
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  identities do
    identity :unique_default_per_org, [:org_id]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
    archive_related [:calls, :user_configs]
  end

end
