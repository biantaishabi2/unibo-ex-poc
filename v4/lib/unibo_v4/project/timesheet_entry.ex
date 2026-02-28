defmodule UniboV4.Project.TimesheetEntry do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Project,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "timesheet_entries"
    repo UniboV4.Repo
  end

  graphql do
    type :timesheet_entry

    mutations do
      create :create_timesheet_entry, :create
      update :update_timesheet_entry, :update
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :hours, :decimal, allow_nil?: false
    attribute :work_date, :date, allow_nil?: false
    attribute :description, :string
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :timesheet, UniboV4.Project.Timesheet do
      allow_nil? false
    end
    belongs_to :task, UniboV4.Project.Task
  end

  actions do
    defaults [:read]
    create :create do
      primary? true
      accept [:hours, :work_date, :description]
      argument :task_id, :uuid
      argument :timesheet_id, :uuid, allow_nil?: false
      change manage_relationship(:timesheet_id, :timesheet, type: :append, on_lookup: :relate)
    end
    update :update do
      primary? true
      accept [:hours, :description]
    end
  end

  validations do
    validate compare(:hours, greater_than: 0)
  end

end
