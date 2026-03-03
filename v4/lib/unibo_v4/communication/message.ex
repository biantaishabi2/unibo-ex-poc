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
    otp_app: :unibo_v4,
    domain: UniboV4.Communication,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

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
    end
    attribute :subject, :string, public?: true
    attribute :message_type, :atom do
      constraints one_of: [:email, :comment, :email_outgoing, :notification, :auto_comment, :user_notification]
      default :comment
      public? true
    end
    attribute :subtype_id, :string, public?: true
    attribute :is_internal, :boolean do
      default false
      public? true
    end
    attribute :is_pinned, :boolean do
      default false
      public? true
    end
    attribute :reply_to, :string, public?: true
    attribute :reply_to_force_new, :boolean do
      default false
      public? true
    end
    attribute :message_id, :string do
      allow_nil? false
      public? true
    end
    attribute :model, :string, public?: true
    attribute :res_id, :integer, public?: true
    attribute :email_from, :string, public?: true
    attribute :partner_ids, :string, public?: true
    attribute :starred_partner_ids, :string, public?: true
    attribute :attachment_ids, :string, public?: true
    attribute :tracking_value_ids, :string, public?: true
    attribute :notification_ids, :string, public?: true
    attribute :sent_at, :utc_datetime do
      allow_nil? false
      default &DateTime.utc_now/0
      public? true
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :channel, UniboV4.Communication.Channel do
      public? true
    end
    belongs_to :author, UniboV4.Communication.User do
      public? true
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
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:content, :subject, :message_type, :subtype_id, :is_internal, :is_pinned, :reply_to_force_new, :model, :res_id, :email_from, :partner_ids, :attachment_ids]
      argument :channel_id, :uuid
      # TODO: 不支持的 action 内校验规则 strip_fields_for_non_employee
      # TODO: 不支持的 action 内校验规则 force_option
      # TODO: 不支持的 action 内校验规则 disable_threading
      # TODO: 不支持的 change effect generate
      # TODO: 不支持的 change effect extract_inline_images
      # TODO: 不支持的 change effect update_all_channel_members
      # TODO: 不支持的 change effect auto_mark_read
      # TODO: 不支持的 change effect sudo_execute
      # TODO: 不支持的 change effect extract_voice_metadata
      change relate_actor(:author)
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
      accept [:content, :is_pinned, :starred_partner_ids, :attachment_ids]
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
    destroy :destroy do
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
    end
    update :toggle_star do
      accept []
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
    action :send_transient do
      # TODO: generic action 不支持 change，需要用 run
    end
  end

end
