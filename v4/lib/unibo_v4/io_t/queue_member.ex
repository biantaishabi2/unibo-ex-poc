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
defmodule UniboV4.IoT.QueueMember do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.IoT,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "io_t_queue_members"
    repo UniboV4.Repo
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
      public? true
    end
    attribute :queue_id, :integer do
      allow_nil? false
      public? true
    end
    attribute :user_id, :integer do
      allow_nil? false
      public? true
    end
    attribute :priority, :integer do
      default 0
      public? true
    end
    attribute :penalty, :integer do
      default 0
      public? true
    end
    attribute :paused, :boolean do
      default false
      public? true
    end
    attribute :paused_reason, :string, public?: true
    attribute :calls_taken, :integer do
      default 0
      public? true
    end
    attribute :last_call_at, :utc_datetime, public?: true
    attribute :avg_talk_time, :integer do
      default 0
      public? true
    end
  end

  calculations do
    # TODO: 不支持的 calculation 表达式 :is_available
    # TODO: 不支持的 calculation 表达式 :idle_time
  end

  relationships do
    belongs_to :queue, UniboV4.IoT.CallQueue do
      public? true
      allow_nil? false
    end
    belongs_to :user, UniboV4.IoT.User do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:queue_id, :user_id, :priority, :penalty]
      argument :queue_id, :uuid, allow_nil?: false
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
    update :pause do
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
      # skipped: validate custom : (incompatible with bulk update atomic path)
      change set_attribute(:paused, true)
      # TODO: 不支持的表达式类型
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
      # skipped: validate custom : (incompatible with bulk update atomic path)
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
      argument :talk_duration, :integer, allow_nil?: false
      # skipped: validate custom : (incompatible with bulk update atomic path)
      # skipped: validate custom : (incompatible with bulk update atomic path)
      change fn changeset, _context ->
        calls_taken = Ash.Changeset.get_attribute(changeset, :calls_taken)

        if calls_taken do
          Ash.Changeset.force_change_attribute(changeset, :calls_taken, Decimal.add(calls_taken, 1))
        else
          changeset
        end
      end
      change set_attribute(:last_call_at, &DateTime.utc_now/0)
      # TODO: 不支持的表达式类型
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

end
