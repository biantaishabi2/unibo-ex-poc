# Workflow: channel_member_manage_flow — 频道维护与成员管理流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
#   add_members --> [*]
#   archive --> [*]
# ```
defmodule UniboExPoc.Communication.Channel do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Communication,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource]

  resource do
    description "频道——消息容器，支持 chat（私聊）、channel（公开频道）、group（群组）三种类型"
  end

  postgres do
    table "communication_channels"
    repo UniboExPoc.Repo
  end

  graphql do
    type :communication_channel

    queries do
      get :get_communication_channel, :read
      list :list_communication_channels, :read
    end

    mutations do
      create :create_communication_channel, :create
      update :update_communication_channel, :update
      update :archive_communication_channel, :archive
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
      description "频道名称；chat 类型由系统自动生成"
    end
    attribute :channel_type, :atom do
      constraints one_of: [:chat, :channel, :group]
      default :channel
      public? true
      description "频道类型，创建后不可变更"
    end
    attribute :uuid, :string do
      allow_nil? false
      public? true
      description "邀请令牌，50 字符唯一随机串，创建时自动生成，不可变"
    end
    attribute :description, :string do
      public? true
      description "频道描述"
    end
    attribute :image_128, :string do
      public? true
      description "自定义头像"
    end
    attribute :active, :boolean do
      default true
      public? true
      description "是否活跃（归档控制）"
    end
    attribute :allow_public_upload, :boolean do
      default false
      public? true
      description "是否允许访客上传文件"
    end
    attribute :group_ids, :string do
      public? true
      description "自动订阅用户组，仅 channel 类型可设；变更时通过 _subscribe_users_automatically() 批量创建成员记录"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :members, UniboExPoc.Communication.ChannelMember do
      public? true
    end
    has_many :messages, UniboExPoc.Communication.Message do
      public? true
    end
    belongs_to :created_by, UniboExPoc.Communication.Party do
      public? true
      source_attribute :created_by_party_id
    end
    belongs_to :group_public, UniboExPoc.Communication.Group do
      public? true
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:name, :channel_type, :description, :image_128, :allow_public_upload, :group_public_id, :group_ids]
      validate present(:group_public_id)
      # message: "公开访问权限组仅 channel 类型可设置"
      validate present(:group_ids)
      # message: "自动订阅用户组仅 channel 类型可设置"
      change relate_actor(:created_by)
      # skipped: set_attribute :group_public_id 引用外部数据 base.group_user
      change UniboExPoc.Communication.Changes.Channel.CreateCall4
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:name, :description, :active, :image_128, :allow_public_upload, :group_public_id, :group_ids]
      # skipped: validate present :group_public_id (incompatible with bulk update atomic path)
      # skipped: validate present :group_ids (incompatible with bulk update atomic path)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :archive do
      description "归档频道，将 active 设为 false"
      accept []
      # skipped: validate present :group_public_id (incompatible with bulk update atomic path)
      # skipped: validate present :group_ids (incompatible with bulk update atomic path)
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :active)
        if current == true do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :active, message: "must equal %{value}", vars: %{value: true}))
        end
      end
      # message: "只有活跃频道可以归档"
      change set_attribute(:active, false)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    action :add_members do
      description "添加成员；创建成员记录 + 发布加入通知 + 广播成员列表 + 可选 RTC 邀请"
      argument :partner_ids, :string, allow_nil?: false
      validate {UniboExPoc.Communication.Validations.Channel.MaxMembers, []}
      # message: "私聊频道最多 2 个成员"
      run fn input, _context ->
        :ok
      end
    end
    action :channel_get do
      description "查找或创建 2 人 chat，为当前用户 pin 频道"
      run fn input, _context ->
        :ok
      end
    end
  end

  validations do
    validate changing(:channel_type, allow: :never)
    validate changing(:uuid, allow: :never)
    # prevent_destroy: 在 destroy action 中通过 change 拒绝操作
    # validation: disable_message_subscribe
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
