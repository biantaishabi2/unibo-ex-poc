# Workflow: mail_group_membership_flow — 邮件组创建与成员加入退出流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   join --> [*]
#   leave --> [*]
#   update --> [*]
#   destroy --> [*]
# ```
defmodule UniboV4.Communication.MailGroup do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Communication,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "邮件组——基于邮件的订阅式讨论组，支持公开/成员/用户组三种访问模式和消息审核"
  end

  postgres do
    table "communication_mail_groups"
    repo UniboV4.Repo
  end

  graphql do
    type :communication_mail_group

    queries do
      get :get_communication_mail_group, :read
      list :list_communication_mail_groups, :read
    end

    mutations do
      create :create_communication_mail_group, :create
      update :update_communication_mail_group, :update
      update :join_communication_mail_group, :join
      update :leave_communication_mail_group, :leave
      destroy :delete_communication_mail_group, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
      description "邮件组名称"
    end
    attribute :description, :string do
      public? true
      description "邮件组描述"
    end
    attribute :active, :boolean do
      default true
      public? true
      description "是否启用"
    end
    attribute :moderation, :boolean do
      default false
      public? true
      description "是否开启消息审核"
    end
    attribute :access_mode, :atom do
      constraints one_of: [:public, :members, :groups]
      default :public
      public? true
      description "访问模式；public 公开，members 仅成员，groups 指定用户组"
    end
    attribute :moderation_notify, :boolean do
      default false
      public? true
      description "是否自动通知待审核消息"
    end
    attribute :moderation_notify_msg, :string do
      public? true
      description "审核通知消息模板"
    end
    attribute :moderation_guidelines, :boolean do
      default false
      public? true
      description "是否向新订阅者发送指南"
    end
    attribute :moderation_guidelines_msg, :string do
      public? true
      description "指南内容"
    end
    attribute :image_128, :string do
      public? true
      description "邮件组图片"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  calculations do
    calculate :member_count, :integer, expr("count(members)")
    calculate :mail_group_message_count, :integer, expr("count(group_messages)")
    calculate :mail_group_message_moderation_count, :integer, expr("count(group_messages, filter: moderation_status == 'pending_moderation')")
    calculate :moderation_rule_count, :integer, expr("count(moderation_rules)")
  end

  relationships do
    has_many :members, UniboV4.Communication.MailGroupMember do
      public? true
    end
    has_many :group_messages, UniboV4.Communication.MailGroupMessage do
      public? true
    end
    has_many :moderation_rules, UniboV4.Communication.MailGroupModeration do
      public? true
    end
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:name, :description, :active, :moderation, :access_mode, :moderation_notify, :moderation_notify_msg, :moderation_guidelines, :moderation_guidelines_msg, :image_128]
      validate present(:name)
      change set_attribute(:id, expr(id))
    end
    update :update do
      primary? true
      accept [:name, :description, :active, :moderation, :access_mode, :moderation_notify, :moderation_notify_msg, :moderation_guidelines, :moderation_guidelines_msg, :image_128]
      # skipped: validate present :name (incompatible with bulk update atomic path)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :join do
      description "当前用户加入邮件组"
      accept []
      # skipped: validate present :name (incompatible with bulk update atomic path)
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
    update :leave do
      description "当前用户离开邮件组"
      accept []
      # skipped: validate present :name (incompatible with bulk update atomic path)
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
      change set_attribute(:id, expr(id))
      require_atomic? false
    end
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
    archive_related [:members, :group_messages, :moderation_rules]
  end

end
