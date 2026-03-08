# Workflow: channel_member_read_state_flow — 成员状态维护与读取位置更新流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
#   mark_fetched --> [*]
#   mark_seen --> [*]
#   destroy --> [*]
# ```
defmodule UniboExPoc.Communication.ChannelMember do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Communication,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "频道成员——记录用户在频道中的成员身份、阅读位置与通知偏好"
  end

  postgres do
    table "communication_channel_members"
    repo UniboExPoc.Repo
  end

  graphql do
    type :communication_channel_member

    queries do
      get :get_communication_channel_member, :read
      list :list_communication_channel_members, :read
      get :get_load_more_members_communication_channel_member, :load_more_members
      list :list_load_more_members_communication_channel_members, :load_more_members
    end

    mutations do
      create :create_communication_channel_member, :create
      update :update_communication_channel_member, :update
      update :mark_seen_communication_channel_member, :mark_seen
      update :mark_fetched_communication_channel_member, :mark_fetched
      destroy :delete_communication_channel_member, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :role, :atom do
      constraints one_of: [:admin, :member]
      default :member
      public? true
      description "成员角色"
    end
    attribute :fold_state, :atom do
      constraints one_of: [:open, :folded, :closed]
      default :closed
      public? true
      description "UI 折叠状态"
    end
    attribute :is_minimized, :boolean do
      default false
      public? true
      description "会话最小化状态"
    end
    attribute :is_pinned, :boolean do
      default true
      public? true
      description "是否在侧边栏显示"
    end
    attribute :custom_channel_name, :string do
      public? true
      description "个人自定义频道名称"
    end
    attribute :custom_notifications, :atom do
      constraints one_of: [:mentions_only, :nothing]
      public? true
      description "个人通知偏好（null 表示使用默认）"
    end
    attribute :mute_until_dt, :utc_datetime do
      public? true
      description "静音截止时间"
    end
    attribute :last_interest_dt, :utc_datetime do
      public? true
      description "最后活跃时间戳"
    end
    attribute :last_seen_dt, :utc_datetime do
      public? true
      description "最后在线时间"
    end
    attribute :joined_date, :date do
      allow_nil? false
      default &Date.utc_today/0
      public? true
      description "加入日期"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :channel, UniboExPoc.Communication.Channel do
      public? true
      allow_nil? false
    end
    belongs_to :user, UniboExPoc.Communication.Party do
      public? true
      source_attribute :user_party_id
    end
    belongs_to :guest, UniboExPoc.Communication.Guest do
      public? true
    end
    belongs_to :seen_message, UniboExPoc.Communication.Message do
      public? true
    end
    belongs_to :fetched_message, UniboExPoc.Communication.Message do
      public? true
    end
    belongs_to :partner, UniboExPoc.Communication.Party do
      public? true
      source_attribute :partner_party_id
    end
    belongs_to :rtc_inviting_session, UniboExPoc.Communication.RTCSession do
      public? true
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:role, :joined_date, :fold_state, :is_minimized, :is_pinned, :custom_channel_name, :custom_notifications, :mute_until_dt]
      argument :channel_id, :uuid, allow_nil?: false
      argument :partner_id, :uuid
      argument :guest_id, :uuid
      change manage_relationship(:channel_id, :channel, type: :append, on_lookup: :relate)
      validate present([:partner_id, :guest_id], exactly: 1)
      # message: "partner_id 和 guest_id 必须二选一，不能同时为空或同时有值"
      change UniboExPoc.Communication.Changes.ChannelMember.CreateCall5
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:fold_state, :is_minimized, :is_pinned, :custom_channel_name, :custom_notifications, :mute_until_dt]
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    destroy :destroy do
      description "删除成员记录 + 广播离开事件 + 发布系统消息（CM-R5 unfollow）"
      primary? true
      change UniboExPoc.Communication.Changes.ChannelMember.DestroyCall4
      change set_attribute(:id, expr(id))
    end
    update :mark_seen do
      description "标记已读位置（使用 FOR NO KEY UPDATE SQL 锁避免并发冲突）"
      accept [:seen_message_id]
      # skipped: validate concurrent_safe : (incompatible with bulk update atomic path)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :mark_fetched do
      description "标记已获取位置"
      accept [:fetched_message_id]
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    read :load_more_members do
      description "成员列表分页加载，每页 100 条（CM-R10）"
    end
  end

  validations do
    # validation: unique_partners_chat
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
  end

end
