# Workflow: channel_member_manage_flow — 频道维护与成员管理流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
#   add_members --> [*]
#   archive --> [*]
# ```
defmodule UniboV4.Communication.Channel do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Communication,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "communication_channels"
    repo UniboV4.Repo
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
    end
    attribute :channel_type, :atom do
      constraints one_of: [:chat, :channel, :group]
      default :channel
      public? true
    end
    attribute :uuid, :string do
      allow_nil? false
      public? true
    end
    attribute :description, :string, public?: true
    attribute :image_128, :string, public?: true
    attribute :active, :boolean do
      default true
      public? true
    end
    attribute :allow_public_upload, :boolean do
      default false
      public? true
    end
    attribute :group_public_id, :uuid, public?: true
    attribute :group_ids, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :members, UniboV4.Communication.ChannelMember do
      public? true
    end
    has_many :messages, UniboV4.Communication.Message do
      public? true
    end
    belongs_to :created_by, UniboV4.Communication.User do
      public? true
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:name, :channel_type, :description, :image_128, :allow_public_upload, :group_public_id, :group_ids]
      # TODO: 不支持的 action 内校验规则 applicable_only_when
      # TODO: 不支持的 action 内校验规则 applicable_only_when
      change relate_actor(:created_by)
      change set_attribute(:group_public_id, :"base.group_user")
      # TODO: 不支持的 change effect generate
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
      accept [:name, :description, :active, :image_128, :allow_public_upload, :group_public_id, :group_ids]
      # skipped: validate applicable_only_when :group_public_id (incompatible with bulk update atomic path)
      # skipped: validate applicable_only_when :group_ids (incompatible with bulk update atomic path)
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
    update :archive do
      accept []
      # skipped: validate applicable_only_when :group_public_id (incompatible with bulk update atomic path)
      # skipped: validate applicable_only_when :group_ids (incompatible with bulk update atomic path)
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
    action :add_members do
      argument :partner_ids, :string, allow_nil?: false
      # TODO: 不支持的 action 内校验规则 max_members
      # TODO: generic action 不支持 change，需要用 run
    end
    action :channel_get do
      # TODO: generic action 不支持 change，需要用 run
    end
  end

  validations do
    # TODO: 不支持的校验规则 readonly_after_create
    # TODO: 不支持的校验规则 readonly_after_create
    # TODO: 不支持的校验规则 prevent_destroy
    # TODO: 不支持的校验规则 disable_message_subscribe
  end

end
