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
defmodule UniboV4.Communication.ChannelMember do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Communication,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "communication_channel_members"
    repo UniboV4.Repo
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
    end
    attribute :fold_state, :atom do
      constraints one_of: [:open, :folded, :closed]
      default :closed
      public? true
    end
    attribute :is_minimized, :boolean do
      default false
      public? true
    end
    attribute :is_pinned, :boolean do
      default true
      public? true
    end
    attribute :custom_channel_name, :string, public?: true
    attribute :custom_notifications, :atom do
      constraints one_of: [:mentions_only, :nothing]
      public? true
    end
    attribute :mute_until_dt, :utc_datetime, public?: true
    attribute :last_interest_dt, :utc_datetime, public?: true
    attribute :last_seen_dt, :utc_datetime, public?: true
    attribute :rtc_inviting_session_id, :uuid, public?: true
    attribute :joined_date, :date do
      allow_nil? false
      default &Date.utc_today/0
      public? true
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :channel, UniboV4.Communication.Channel do
      public? true
      allow_nil? false
    end
    belongs_to :user, UniboV4.Communication.User do
      public? true
    end
    belongs_to :guest, UniboV4.Communication.Guest do
      public? true
    end
    belongs_to :seen_message, UniboV4.Communication.Message do
      public? true
    end
    belongs_to :fetched_message, UniboV4.Communication.Message do
      public? true
    end
    belongs_to :partner, UniboV4.Communication.User do
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
      # TODO: 不支持的 action 内校验规则 exactly_one_of
      # TODO: 不支持的 change effect broadcast_event
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
      accept [:fold_state, :is_minimized, :is_pinned, :custom_channel_name, :custom_notifications, :mute_until_dt]
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
      primary? true
      # TODO: 不支持的 change effect broadcast_event
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
    end
    update :mark_seen do
      # skipped: validate concurrent_safe : (incompatible with bulk update atomic path)
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
    update :mark_fetched do
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
    read :load_more_members do
    end
  end

  validations do
    # TODO: 不支持的校验规则 unique_constraint
  end

end
