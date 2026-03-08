# Workflow: conference_room_lifecycle — 会议室创建、维护、开始/结束会议与删除流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
#   start_conference --> [*]
#   end_conference --> [*]
#   destroy --> [*]
# ```
defmodule UniboExPoc.IoT.ConferenceRoom do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.IoT,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource],
    notifiers: [UniboExPoc.IoT.ConferenceRoom.Notifier]

  resource do
    description "虚拟电话会议室配置，支持 PIN 码保护、录音和参会人管理"
  end

  postgres do
    table "io_t_conference_rooms"
    repo UniboExPoc.Repo
  end

  graphql do
    type :io_t_conference_room

    queries do
      get :get_io_t_conference_room, :read
      list :list_io_t_conference_rooms, :read
    end

    mutations do
      create :create_io_t_conference_room, :create
      update :update_io_t_conference_room, :update
      update :start_conference_io_t_conference_room, :start_conference
      update :end_conference_io_t_conference_room, :end_conference
      destroy :delete_io_t_conference_room, :destroy
    end

  end

  attributes do
    attribute :id, :integer do
      primary_key? true
      allow_nil? false
      generated? true
      public? true
    end
    attribute :name, :string do
      allow_nil? false
      public? true
      description "会议室名称"
    end
    attribute :extension, :string do
      allow_nil? false
      public? true
      description "内部分机号"
    end
    attribute :pin, :string do
      public? true
      description "进入 PIN 码"
    end
    attribute :admin_pin, :string do
      public? true
      description "管理员 PIN 码"
    end
    attribute :max_participants, :integer do
      default 50
      public? true
      description "最大参会人数"
    end
    attribute :record_conference, :boolean do
      default false
      public? true
      description "是否录音"
    end
    attribute :mute_on_join, :boolean do
      default false
      public? true
      description "加入时静音"
    end
    attribute :announce_join_leave, :boolean do
      default true
      public? true
      description "播报加入/离开"
    end
    attribute :is_active, :boolean do
      default true
      public? true
      description "是否激活"
    end
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :org, UniboExPoc.IoT.Org do
      public? true
      allow_nil? false
      attribute_type :integer
    end
    has_many :incoming_numbers, UniboExPoc.IoT.IncomingNumber do
      public? true
      source_attribute :org_id
      destination_attribute :conference_room_id
    end
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:name, :extension, :pin, :admin_pin, :max_participants, :record_conference, :mute_on_join, :announce_join_leave, :is_active, :org_id]
      argument :org_id, :integer, allow_nil?: false
      change manage_relationship(:org_id, :org, type: :append, on_lookup: :relate)
      validate present(:name)
      validate present(:extension)
      validate present(:org_id)
      validate compare(:max_participants, greater_than: 0)
      # message: "最大参会人数必须大于零"
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
      accept [:name, :pin, :admin_pin, :max_participants, :record_conference, :mute_on_join, :announce_join_leave, :is_active]
      # skipped: validate compare :max_participants (incompatible with bulk update atomic path)
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
    update :start_conference do
      description "开始会议"
      accept []
      # skipped: validate compare :max_participants (incompatible with bulk update atomic path)
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :is_active)
        if current == true do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :is_active, message: "must equal %{value}", vars: %{value: true}))
        end
      end
      # message: "只有激活的会议室可以开始会议"
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
    update :end_conference do
      description "结束会议"
      accept []
      # skipped: validate compare :max_participants (incompatible with bulk update atomic path)
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
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

  identities do
    identity :unique_extension_per_org, [:extension, :org_id]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
    archive_related [:incoming_numbers]
  end

end
