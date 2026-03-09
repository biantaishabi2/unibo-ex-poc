# Workflow: voip_user_config_lifecycle — 用户 VoIP 配置创建、更新、DND 切换、转发设置流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
#   toggle_dnd --> [*]
#   set_forwarding --> [*]
# ```
defmodule UniboExPoc.IoT.VoIPUserConfig do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.IoT,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource]

  resource do
    description "每个用户的 VoIP 偏好设置，包含 SIP 凭据、免打扰、呼叫转移等行为配置"
  end

  postgres do
    table "io_t_vo_ip_user_configs"
    repo UniboExPoc.Repo
  end

  graphql do
    type :io_t_vo_ip_user_config

    queries do
      get :get_io_t_vo_ip_user_config, :read
      list :list_io_t_vo_ip_user_configs, :read
    end

    mutations do
      create :create_io_t_vo_ip_user_config, :create
      update :update_io_t_vo_ip_user_config, :update
      update :toggle_dnd_io_t_vo_ip_user_config, :toggle_dnd
      update :set_forwarding_io_t_vo_ip_user_config, :set_forwarding
    end

  end

  attributes do
    attribute :id, :integer do
      primary_key? true
      allow_nil? false
      generated? true
      public? true
    end
    attribute :extension, :string do
      public? true
      description "分机号"
    end
    attribute :sip_login, :string do
      public? true
      description "SIP 用户名"
    end
    attribute :sip_secret, :string do
      public? true
      description "SIP 密码（AES-256 加密存储）"
    end
    attribute :dnd, :boolean do
      default false
      public? true
      description "免打扰"
    end
    attribute :auto_answer, :boolean do
      default false
      public? true
      description "自动接听"
    end
    attribute :ring_timeout, :integer do
      default 30
      public? true
      description "振铃超时秒数"
    end
    attribute :outgoing_caller_id, :string do
      public? true
      description "外呼显示号码（动态来电显示）"
    end
    attribute :forward_on_busy, :string do
      public? true
      description "忙时转发号码"
    end
    attribute :forward_on_no_answer, :string do
      public? true
      description "无应答转发号码"
    end
    attribute :forward_unconditional, :string do
      public? true
      description "无条件转发号码"
    end
    attribute :follow_me_enabled, :boolean do
      default false
      public? true
      description "是否启用 Follow Me"
    end
    attribute :follow_me_number, :string do
      public? true
      description "Follow Me 外部号码"
    end
    attribute :voicemail_enabled, :boolean do
      default true
      public? true
      description "是否启用语音信箱"
    end
  end

  relationships do
    belongs_to :user, UniboExPoc.IoT.Party do
      public? true
      allow_nil? false
      source_attribute :user_party_id
    end
    belongs_to :provider, UniboExPoc.IoT.VoIPProvider do
      public? true
      attribute_type :integer
    end
    belongs_to :org, UniboExPoc.IoT.Org do
      public? true
      allow_nil? false
      attribute_type :integer
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:extension, :sip_login, :sip_secret, :dnd, :auto_answer, :ring_timeout, :outgoing_caller_id, :forward_on_busy, :forward_on_no_answer, :forward_unconditional, :follow_me_enabled, :follow_me_number, :voicemail_enabled, :org_id]
      argument :user_id, :integer, allow_nil?: false
      argument :provider_id, :integer
      change manage_relationship(:user_id, :user, type: :append, on_lookup: :relate)
      argument :org_id, :integer, allow_nil?: false
      change manage_relationship(:org_id, :org, type: :append, on_lookup: :relate)
      validate present(:org_id)
      validate present([:user_id])
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:extension, :sip_login, :sip_secret, :auto_answer, :ring_timeout, :outgoing_caller_id, :voicemail_enabled]
      argument :provider_id, :integer
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :toggle_dnd do
      description "切换免打扰状态"
      accept []
      change set_attribute(:dnd, expr(not dnd))
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :set_forwarding do
      description "设置呼叫转发规则"
      accept [:forward_on_busy, :forward_on_no_answer, :forward_unconditional, :follow_me_enabled, :follow_me_number]
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  identities do
    identity :unique_user_voip_config, [:user_id, :org_id]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
