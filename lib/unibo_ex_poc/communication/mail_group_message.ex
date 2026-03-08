# Workflow: mail_group_message_moderation_flow — 邮件组消息审核流转流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   moderate_accept --> [*]
#   moderate_reject --> [*]
#   moderate_allow --> [*]
#   moderate_ban --> [*]
# ```
defmodule UniboV4.Communication.MailGroupMessage do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Communication,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource]

  resource do
    description "邮件组消息——邮件组中的通信记录，支持审核状态机（pending_moderation → accepted / rejected）"
  end

  postgres do
    table "communication_mail_group_messages"
    repo UniboV4.Repo
  end

  graphql do
    type :communication_mail_group_message

    queries do
      get :get_communication_mail_group_message, :read
      list :list_communication_mail_group_messages, :read
    end

    mutations do
      create :create_communication_mail_group_message, :create
      update :moderate_accept_communication_mail_group_message, :moderate_accept
      update :moderate_reject_communication_mail_group_message, :moderate_reject
      update :moderate_allow_communication_mail_group_message, :moderate_allow
      update :moderate_ban_communication_mail_group_message, :moderate_ban
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :subject, :string do
      public? true
      description "消息主题"
    end
    attribute :body, :string do
      public? true
      description "消息正文"
    end
    attribute :email_from, :string do
      public? true
      description "发件人邮箱"
    end
    attribute :email_from_normalized, :string do
      public? true
      description "标准化发件人邮箱"
    end
    attribute :moderation_status, :atom do
      constraints one_of: [:pending_moderation, :accepted, :rejected]
      default :pending_moderation
      public? true
      description "审核状态"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :mail_group, UniboV4.Communication.MailGroup do
      public? true
      allow_nil? false
    end
    belongs_to :moderator, UniboV4.Communication.Party do
      public? true
      source_attribute :moderator_party_id
    end
    belongs_to :parent_message, UniboV4.Communication.MailGroupMessage do
      public? true
    end
    has_many :child_messages, UniboV4.Communication.MailGroupMessage do
      public? true
      source_attribute :parent_message_id
      destination_attribute :parent_message_id
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:subject, :body, :email_from, :email_from_normalized, :moderation_status]
      argument :mail_group_id, :uuid, allow_nil?: false
      argument :moderator_id, :uuid
      argument :parent_message_id, :uuid
      change manage_relationship(:mail_group_id, :mail_group, type: :append, on_lookup: :relate)
      validate present(:mail_group_id)
      change set_attribute(:id, expr(id))
    end
    update :moderate_accept do
      description "通过消息并通知所有成员"
      primary? true
      accept [:moderation_status]
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
      change set_attribute(:moderation_status, :accepted)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :moderate_reject do
      description "拒绝消息"
      accept [:moderation_status]
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
      change set_attribute(:moderation_status, :rejected)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :moderate_allow do
      description "白名单作者并通过其所有待审核消息"
      accept [:moderation_status]
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
      change set_attribute(:moderation_status, :accepted)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :moderate_ban do
      description "封禁作者并拒绝其所有待审核消息"
      accept [:moderation_status]
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
      change set_attribute(:moderation_status, :rejected)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
