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
    otp_app: :unibo_v4,
    domain: UniboV4.Communication,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

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
    end
    attribute :description, :string, public?: true
    attribute :active, :boolean do
      default true
      public? true
    end
    attribute :moderation, :boolean do
      default false
      public? true
    end
    attribute :access_mode, :atom do
      constraints one_of: [:public, :members, :groups]
      default :public
      public? true
    end
    attribute :moderation_notify, :boolean do
      default false
      public? true
    end
    attribute :moderation_notify_msg, :string, public?: true
    attribute :moderation_guidelines, :boolean do
      default false
      public? true
    end
    attribute :moderation_guidelines_msg, :string, public?: true
    attribute :image_128, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  calculations do
    # TODO: 不支持的 calculation 表达式 :member_count
    # TODO: 不支持的 calculation 表达式 :mail_group_message_count
    # TODO: 不支持的 calculation 表达式 :mail_group_message_moderation_count
    # TODO: 不支持的 calculation 表达式 :moderation_rule_count
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
      accept [:name, :description, :active, :moderation, :access_mode, :moderation_notify, :moderation_notify_msg, :moderation_guidelines, :moderation_guidelines_msg, :image_128]
      # skipped: validate present :name (incompatible with bulk update atomic path)
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
    update :join do
      accept []
      # skipped: validate present :name (incompatible with bulk update atomic path)
      # skipped: validate custom : (incompatible with bulk update atomic path)
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
    update :leave do
      accept []
      # skipped: validate present :name (incompatible with bulk update atomic path)
      # skipped: validate custom : (incompatible with bulk update atomic path)
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

end
