# Workflow: queue_member_availability_flow — 队列成员创建、调度状态维护、通话记录与删除流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> [*]
#   update --> [*]
#   pause --> [*]
#   unpause --> [*]
#   record_call --> [*]
#   destroy --> [*]
# ```
defmodule UniboExPoc.IoT.QueueMember do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.IoT,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "队列成员/坐席，通过 paused 字段控制是否接听，支持 wrapup 自动暂停，区分静态/动态坐席"
  end

  postgres do
    table "io_t_queue_members"
    repo UniboExPoc.Repo
  end

  graphql do
    type :io_t_queue_member

    queries do
      get :get_io_t_queue_member, :read
      list :list_io_t_queue_members, :read
    end

    mutations do
      create :create_io_t_queue_member, :create
      update :update_io_t_queue_member, :update
      update :pause_io_t_queue_member, :pause
      update :unpause_io_t_queue_member, :unpause
      update :record_call_io_t_queue_member, :record_call
      destroy :delete_io_t_queue_member, :destroy
    end

  end

  attributes do
    attribute :id, :integer do
      primary_key? true
      allow_nil? false
      generated? true
      public? true
    end
    attribute :priority, :integer do
      default 0
      public? true
      description "优先级（越小越先振铃）"
    end
    attribute :penalty, :integer do
      default 0
      public? true
      description "惩罚值（影响 wrandom 策略）"
    end
    attribute :paused, :boolean do
      default false
      public? true
      description "是否暂停接听"
    end
    attribute :paused_reason, :string do
      public? true
      description "暂停原因"
    end
    attribute :calls_taken, :integer do
      default 0
      public? true
      description "已接通话数"
    end
    attribute :last_call_at, :utc_datetime do
      public? true
      description "最后接听时间"
    end
    attribute :avg_talk_time, :integer do
      default 0
      public? true
      description "平均通话时长（秒）"
    end
    attribute :member_type, :atom do
      constraints one_of: [:static, :dynamic]
      default :static
      public? true
      description "坐席类型。static=管理员预分配，dynamic=坐席自行登入/登出"
    end
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  calculations do
    calculate :is_available, :boolean, expr((paused == false and user.voip_user_config == false))
    calculate :idle_time, :integer, expr(datetime_diff_seconds(now, last_call_at))
  end

  relationships do
    belongs_to :queue, UniboExPoc.IoT.CallQueue do
      public? true
      allow_nil? false
      attribute_type :integer
    end
    belongs_to :user, UniboExPoc.IoT.Party do
      public? true
      allow_nil? false
      source_attribute :user_party_id
    end
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:queue_id, :priority, :penalty, :member_type]
      argument :user_id, :uuid
      argument :queue_id, :integer, allow_nil?: false
      change manage_relationship(:queue_id, :queue, type: :append, on_lookup: :relate)
      argument :user_id, :uuid, allow_nil?: false
      change manage_relationship(:user_id, :user, type: :append, on_lookup: :relate)
      validate present(:queue_id)
      validate present(:user_id)
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
      accept [:priority, :penalty]
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
    update :pause do
      description "暂停接听"
      argument :reason, :string
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :paused)
        if current == false do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :paused, message: "must equal %{value}", vars: %{value: false}))
        end
      end
      # message: "已暂停成员不能重复暂停"
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
      change set_attribute(:paused, true)
      change set_attribute(:paused_reason, ^arg(:reason))
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
    update :unpause do
      description "恢复接听"
      accept []
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :paused)
        if current == true do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :paused, message: "must equal %{value}", vars: %{value: true}))
        end
      end
      # message: "仅暂停中的成员允许恢复接听"
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
      change set_attribute(:paused, false)
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
    update :record_call do
      description "记录一次通话接听"
      argument :talk_duration, :integer, allow_nil?: false
      # skipped: validate compare :duration (incompatible with bulk update atomic path)
      # skipped: validate custom_check : (incompatible with bulk update atomic path)
      change fn changeset, _context ->
        calls_taken = Ash.Changeset.get_attribute(changeset, :calls_taken)

        if calls_taken do
          Ash.Changeset.force_change_attribute(changeset, :calls_taken, (calls_taken + 1))
        else
          changeset
        end
      end
      change set_attribute(:last_call_at, &DateTime.utc_now/0)
      change fn changeset, _context ->
        avg_talk_time = Ash.Changeset.get_attribute(changeset, :avg_talk_time)
        calls_taken = Ash.Changeset.get_attribute(changeset, :calls_taken)
        calls_taken = Ash.Changeset.get_attribute(changeset, :calls_taken)

        if avg_talk_time && calls_taken && calls_taken do
          Ash.Changeset.force_change_attribute(changeset, :avg_talk_time, (((avg_talk_time * (calls_taken - 1)) + ^arg(:talk_duration)) / calls_taken))
        else
          changeset
        end
      end
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
    identity :unique_member_per_queue, [:queue_id, :user_id]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
  end

end
