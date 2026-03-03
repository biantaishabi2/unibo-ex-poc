# Workflow: week_exception_manage_flow — 周例外管理
# ```mermaid
# stateDiagram-v2
#   [*] --> add
#   add --> remove
#   remove --> [*]
# ```
defmodule UniboV4.Calendar.Calendar.WeekException do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Calendar.Calendar,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "calendar_week_exceptions"
    repo UniboV4.Repo
  end

  graphql do
    type :calendar_week_exception

    queries do
      get :get_calendar_week_exception, :read
      list :list_calendar_week_exceptions, :read
    end

    mutations do
      create :create_add_calendar_week_exception, :add
      destroy :delete_remove_calendar_week_exception, :remove
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :start_date, :date do
      allow_nil? false
      public? true
    end
    attribute :end_date, :date do
      allow_nil? false
      public? true
    end
    attribute :description, :string, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :work_schedule, UniboV4.Calendar.Calendar.WorkSchedule do
      public? true
      allow_nil? false
    end
    belongs_to :override_week_template, UniboV4.Calendar.Calendar.WeekTemplate do
      public? true
    end
    has_many :translations, UniboV4.Calendar.Calendar.WeekExceptionTranslation, public?: true
  end

  actions do
    defaults [:read, :update]
    create :add do
      primary? true
      accept [:start_date, :end_date, :description]
      argument :override_week_template_id, :uuid, allow_nil?: false
      argument :work_schedule_id, :uuid, allow_nil?: false
      change manage_relationship(:work_schedule_id, :work_schedule, type: :append, on_lookup: :relate)
      validate present(:work_schedule_id)
      validate present(:start_date)
      validate present(:end_date)
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
    end
    destroy :remove do
      primary? true
      change fn changeset, _context ->
        id = Ash.Changeset.get_attribute(changeset, :id)

        if id do
          Ash.Changeset.force_change_attribute(changeset, :id, id)
        else
          changeset
        end
      end
    end
  end

  validations do
    validate compare(:end_date, greater_than: :start_date)
  end

end
