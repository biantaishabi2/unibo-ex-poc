# Workflow: timesheet_entry_management — 工时记录管理流程
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   update --> update
# ```
defmodule UniboExPoc.Helpdesk.FsmTimesheetEntry do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Helpdesk,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource]

  resource do
    description "现场服务工时记录"
  end

  postgres do
    table "helpdesk_fsm_timesheet_entries"
    repo UniboExPoc.Repo
  end

  graphql do
    type :helpdesk_fsm_timesheet_entry

    queries do
      get :get_helpdesk_fsm_timesheet_entry, :read
      list :list_helpdesk_fsm_timesheet_entrys, :read
    end

    mutations do
      create :create_helpdesk_fsm_timesheet_entry, :create
      update :update_helpdesk_fsm_timesheet_entry, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :date, :date do
      allow_nil? false
      public? true
      description "工时日期"
    end
    attribute :hours, :decimal do
      allow_nil? false
      public? true
      description "工时小时数"
    end
    attribute :description, :string do
      public? true
      description "工时描述/备注"
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :service_order, UniboExPoc.Helpdesk.FieldServiceOrder do
      public? true
      allow_nil? false
    end
    belongs_to :technician, UniboExPoc.Helpdesk.Party do
      public? true
      allow_nil? false
      source_attribute :technician_party_id
    end
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:date, :hours, :description]
      argument :service_order_id, :uuid, allow_nil?: false
      argument :technician_id, :uuid, allow_nil?: false
      change manage_relationship(:service_order_id, :service_order, type: :append, on_lookup: :relate)
      change manage_relationship(:technician_id, :technician, type: :append, on_lookup: :relate)
      validate present(:date)
      # message: "工时日期必填"
      validate present(:hours)
      # message: "工时小时数必填"
      validate compare(:hours, greater_than: 0)
      # message: "工时小时数必须大于 0"
      validate present(:service_order)
      # message: "必须关联现场服务任务"
      validate present(:technician)
      # message: "必须指定技术员"
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
      accept [:date, :hours, :description]
      # skipped: validate compare :hours (incompatible with bulk update atomic path)
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
