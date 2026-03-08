# Workflow: sla_tracking_lifecycle — SLA 追踪实例生命周期（二态终结状态机）
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> check_and_update
#   create --> accumulate_excluded_time
#   check_and_update --> mark_reached
#   check_and_update --> mark_failed
#   check_and_update --> accumulate_excluded_time
#   mark_reached --> [*]
#   mark_failed --> [*]
#   accumulate_excluded_time --> check_and_update
#   accumulate_excluded_time --> accumulate_excluded_time
# ```
defmodule UniboExPoc.Helpdesk.HelpdeskSLAStatus do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Helpdesk,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource]

  resource do
    description "SLA 追踪实例，二态终结状态机（reached/failed 不可逆）"
  end

  postgres do
    table "helpdesk_sla_statuses"
    repo UniboExPoc.Repo
  end

  graphql do
    type :helpdesk_helpdesk_sla_status

    queries do
      get :get_helpdesk_helpdesk_sla_status, :read
      list :list_helpdesk_helpdesk_sla_statuss, :read
    end

    mutations do
      create :create_helpdesk_helpdesk_sla_status, :create
      update :check_and_update_helpdesk_helpdesk_sla_status, :check_and_update
      update :mark_reached_helpdesk_helpdesk_sla_status, :mark_reached
      update :mark_failed_helpdesk_helpdesk_sla_status, :mark_failed
      update :accumulate_excluded_time_helpdesk_helpdesk_sla_status, :accumulate_excluded_time
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :deadline, :utc_datetime do
      allow_nil? false
      public? true
      description "计算出的截止时间"
    end
    attribute :reached_date, :utc_datetime do
      public? true
      description "实际到达目标阶段的时间"
    end
    attribute :status, :atom do
      allow_nil? false
      constraints one_of: [:in_progress, :reached, :failed]
      default :in_progress
      public? true
      description "追踪状态 — reached 和 failed 为终态不可逆转"
    end
    attribute :exceeded_hours, :decimal do
      public? true
      description "超时小时数（正=提前完成/超时，视达标或失败而定）"
    end
    attribute :excluded_time_hours, :decimal do
      allow_nil? false
      default 0.0
      public? true
      description "累计排除的暂停时间（小时）"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :ticket, UniboExPoc.Helpdesk.HelpdeskTicket do
      public? true
      allow_nil? false
    end
    belongs_to :sla, UniboExPoc.Helpdesk.HelpdeskSLA do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:deadline, :excluded_time_hours]
      argument :ticket_id, :uuid, allow_nil?: false
      argument :sla_id, :uuid, allow_nil?: false
      change manage_relationship(:ticket_id, :ticket, type: :append, on_lookup: :relate)
      change manage_relationship(:sla_id, :sla, type: :append, on_lookup: :relate)
      validate present(:ticket)
      validate present(:sla)
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
    end
    update :check_and_update do
      description "R25: 在每次阶段变更时调用，遍历工单所有 in_progress 的 SLA 追踪记录并更新状态
R26: 判定达标 — ticket.stage.sequence >= sla.reach_stage.sequence
R27: 判定失败 — now > deadline 且尚未达到目标阶段
"
      primary? true
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
    update :mark_reached do
      description "标记为已达标（终态不可逆）"
      accept [:reached_date, :exceeded_hours]
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :in_progress do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :in_progress}))
        end
      end
      # message: "只有 in_progress 状态的 SLA 追踪记录可以更新（终态不可逆）"
      change set_attribute(:status, :reached)
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
    update :mark_failed do
      description "标记为已失败（终态不可逆）"
      accept [:exceeded_hours]
      change fn changeset, _ctx ->
        current = Ash.Changeset.get_attribute(changeset, :status)
        if current == :in_progress do
          changeset
        else
          Ash.Changeset.add_error(changeset, Ash.Error.Changes.InvalidAttribute.exception(field: :status, message: "must equal %{value}", vars: %{value: :in_progress}))
        end
      end
      # message: "只有 in_progress 状态的 SLA 追踪记录可以更新（终态不可逆）"
      change set_attribute(:status, :failed)
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
    update :accumulate_excluded_time do
      description "R29 工单进入/离开排除阶段时累加暂停工作时间"
      accept [:excluded_time_hours]
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

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

end
