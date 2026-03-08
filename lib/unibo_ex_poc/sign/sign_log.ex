# Workflow: sign_log_audit_flow — 审计日志创建与读取流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   read --> [*]
# ```
defmodule UniboV4.Sign.SignLog do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Sign,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "签名审计日志，记录一旦创建不可修改、不可删除，使用 SHA256 哈希链保证完整性"
  end

  postgres do
    table "sign_logs"
    repo UniboV4.Repo
  end

  graphql do
    type :sign_sign_log

    queries do
      get :get_sign_sign_log, :read
      list :list_sign_sign_logs, :read
    end

    mutations do
      create :create_sign_sign_log, :create
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :action, :atom do
      allow_nil? false
      constraints one_of: [:created, :sent, :open, :sign, :refuse, :update, :reassign, :recall, :reminded, :canceled]
      public? true
      description "操作类型"
    end
    attribute :ip_address, :string do
      public? true
      description "操作时 IP 地址"
    end
    attribute :user_agent, :string do
      public? true
      description "浏览器 User-Agent"
    end
    attribute :log_hash, :string do
      allow_nil? false
      public? true
      description "SHA256 哈希链值，hash_n = SHA256(hash_{n-1} | action | timestamp | ip | ua)"
    end
    attribute :timestamp, :utc_datetime do
      allow_nil? false
      public? true
      description "操作时间（精确到毫秒）"
    end
    attribute :note, :string do
      public? true
      description "附加说明（如拒签理由）"
    end
    attribute :metadata, :string do
      public? true
      description "附加元数据"
    end
  end

  relationships do
    belongs_to :request, UniboV4.Sign.SignRequest do
      public? true
      allow_nil? false
    end
    belongs_to :request_item, UniboV4.Sign.SignRequestItem do
      public? true
    end
    belongs_to :actor, UniboV4.Sign.Party do
      public? true
      source_attribute :actor_party_id
    end
  end

  actions do
    defaults [:read, :update]
    create :create do
      primary? true
      accept [:action, :ip_address, :user_agent, :note, :metadata]
      argument :request_id, :uuid, allow_nil?: false
      argument :request_item_id, :uuid
      argument :actor_id, :uuid
      change manage_relationship(:request_id, :request, type: :append, on_lookup: :relate)
      validate present(:action)
      validate present(:timestamp)
      change UniboV4.Sign.Changes.SignLog.ComputeTimestamp
      change UniboV4.Sign.Changes.SignLog.ComputeLogHash
      change set_attribute(:id, expr(id))
    end
  end

end
