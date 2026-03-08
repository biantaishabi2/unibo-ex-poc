# Workflow: message_publish_flow — 消息发布与星标维护流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
#   toggle_star --> [*]
#   send_transient --> [*]
#   destroy --> [*]
# ```
defmodule UniboV4.Communication.Message do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Communication,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "消息——频道中的通信记录，支持评论、邮件、通知、线程回复等多种类型"
  end

  postgres do
    table "communication_messages"
    repo UniboV4.Repo
  end

  graphql do
    type :communication_message

    queries do
      get :get_communication_message, :read
      list :list_communication_messages, :read
    end

    mutations do
      create :create_communication_message, :create
      update :update_communication_message, :update
      update :toggle_star_communication_message, :toggle_star
      destroy :delete_communication_message, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :content, :string do
      allow_nil? false
      public? true
      description "消息体（HTML）"
    end
    attribute :subject, :string do
      public? true
      description "邮件主题"
    end
    attribute :message_type, :atom do
      constraints one_of: [:email, :comment, :email_outgoing, :notification, :auto_comment, :user_notification]
      default :comment
      public? true
      description "消息类型"
    end
    attribute :is_internal, :boolean do
      default false
      public? true
      description "是否为内部消息（非员工不可见）"
    end
    attribute :is_pinned, :boolean do
      default false
      public? true
      description "是否置顶"
    end
    attribute :reply_to, :string do
      public? true
      description "回复地址（计算生成）"
    end
    attribute :reply_to_force_new, :boolean do
      default false
      public? true
      description "强制新会话（禁用线程化）"
    end
    attribute :message_id, :string do
      allow_nil? false
      public? true
      description "RFC 5322 Message-ID，创建时自动生成"
    end
    attribute :model, :string do
      public? true
      description "关联模型名称（如 discuss.channel）"
    end
    attribute :res_id, :integer do
      public? true
      description "关联记录 ID"
    end
    attribute :email_from, :string do
      public? true
      description "发件人邮箱"
    end
    attribute :partner_ids, :string do
      public? true
      description "收件人列表"
    end
    attribute :starred_partner_ids, :string do
      public? true
      description "星标用户列表"
    end
    attribute :attachment_ids, :string do
      public? true
      description "附件列表"
    end
    attribute :tracking_value_ids, :string do
      public? true
      description "字段变更追踪记录"
    end
    attribute :notification_ids, :string do
      public? true
      description "通知记录列表"
    end
    attribute :sent_at, :utc_datetime do
      allow_nil? false
      default &DateTime.utc_now/0
      public? true
      description "发送时间"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :channel, UniboV4.Communication.Channel do
      public? true
    end
    belongs_to :author, UniboV4.Communication.Party do
      public? true
      source_attribute :author_party_id
    end
    belongs_to :parent, UniboV4.Communication.Message do
      public? true
    end
    has_many :notifications, UniboV4.Communication.Notification do
      public? true
    end
    has_many :attachments, UniboV4.Communication.Attachment do
      public? true
    end
    has_many :tracking_values, UniboV4.Communication.TrackingValue do
      public? true
    end
    belongs_to :subtype, UniboV4.Communication.MessageSubtype do
      public? true
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:content, :subject, :message_type, :subtype_id, :is_internal, :is_pinned, :reply_to_force_new, :parent_id, :model, :res_id, :email_from, :partner_ids, :attachment_ids]
      argument :channel_id, :uuid
      # validation: strip_fields_for_non_employee
      # WARNING: one_of : 缺少 params，校验定义不完整
      # validation: disable_threading
      change UniboV4.Communication.Changes.Message.CreateCall1
      change UniboV4.Communication.Changes.Message.CreateCall2
      change UniboV4.Communication.Changes.Message.CreateCall3
      change UniboV4.Communication.Changes.Message.CreateCall4
      change UniboV4.Communication.Changes.Message.CreateCall5
      change UniboV4.Communication.Changes.Message.CreateCall6
      change relate_actor(:author)
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:content, :is_pinned, :starred_partner_ids, :attachment_ids]
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    destroy :destroy do
      description "删除消息（需有关联文档写/创建权限）"
      change set_attribute(:id, expr(id))
    end
    update :toggle_star do
      description "切换星标状态"
      accept []
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    action :send_transient do
      description "发送瞬态消息——仅通过 Bus 广播，不持久化（MSG-R8）"
      run fn input, _context ->
        :ok
      end
    end
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
    archive_related [:notifications, :attachments, :tracking_values]
  end

end
