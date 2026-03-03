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
    otp_app: :unibo_v4,
    domain: UniboV4.Communication,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

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
    attribute :subject, :string, public?: true
    attribute :body, :string, public?: true
    attribute :email_from, :string, public?: true
    attribute :email_from_normalized, :string, public?: true
    attribute :moderation_status, :atom do
      constraints one_of: [:pending_moderation, :accepted, :rejected]
      default :pending_moderation
      public? true
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :mail_group, UniboV4.Communication.MailGroup do
      public? true
      allow_nil? false
    end
    belongs_to :moderator, UniboV4.Communication.User do
      public? true
    end
    belongs_to :parent_message, UniboV4.Communication.MailGroupMessage do
      public? true
    end
    has_many :child_messages, UniboV4.Communication.MailGroupMessage do
      public? true
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
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
    end
    update :moderate_accept do
      primary? true
      accept [:moderation_status]
      # skipped: validate custom : (incompatible with bulk update atomic path)
      change set_attribute(:moderation_status, :accepted)
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
    update :moderate_reject do
      accept [:moderation_status]
      # skipped: validate custom : (incompatible with bulk update atomic path)
      change set_attribute(:moderation_status, :rejected)
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
    update :moderate_allow do
      accept [:moderation_status]
      # skipped: validate custom : (incompatible with bulk update atomic path)
      change set_attribute(:moderation_status, :accepted)
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
    update :moderate_ban do
      accept [:moderation_status]
      # skipped: validate custom : (incompatible with bulk update atomic path)
      change set_attribute(:moderation_status, :rejected)
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
