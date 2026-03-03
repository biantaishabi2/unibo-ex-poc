# Workflow: week_template_maintain_flow — 周模板维护
# ```mermaid
# stateDiagram-v2
#   [*] --> create
#   create --> update
#   create --> destroy
#   update --> destroy
#   destroy --> [*]
# ```
defmodule UniboV4.Calendar.Calendar.WeekTemplate do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Calendar.Calendar,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "calendar_week_templates"
    repo UniboV4.Repo
  end

  graphql do
    type :calendar_week_template

    queries do
      get :get_calendar_week_template, :read
      list :list_calendar_week_templates, :read
    end

    mutations do
      create :create_calendar_week_template, :create
      update :update_calendar_week_template, :update
      destroy :delete_calendar_week_template, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string do
      allow_nil? false
      public? true
    end
    attribute :description, :string, public?: true
    attribute :monday_start, :string, public?: true
    attribute :monday_capacity, :float do
      default 0.0
      public? true
    end
    attribute :tuesday_start, :string, public?: true
    attribute :tuesday_capacity, :float do
      default 0.0
      public? true
    end
    attribute :wednesday_start, :string, public?: true
    attribute :wednesday_capacity, :float do
      default 0.0
      public? true
    end
    attribute :thursday_start, :string, public?: true
    attribute :thursday_capacity, :float do
      default 0.0
      public? true
    end
    attribute :friday_start, :string, public?: true
    attribute :friday_capacity, :float do
      default 0.0
      public? true
    end
    attribute :saturday_start, :string, public?: true
    attribute :saturday_capacity, :float do
      default 0.0
      public? true
    end
    attribute :sunday_start, :string, public?: true
    attribute :sunday_capacity, :float do
      default 0.0
      public? true
    end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :work_schedules, UniboV4.Calendar.Calendar.WorkSchedule do
      public? true
      destination_attribute :week_template_id
    end
    has_many :translations, UniboV4.Calendar.Calendar.WeekTemplateTranslation, public?: true
  end

  actions do
    defaults [:read, :destroy]
    create :create do
      primary? true
      accept [:name, :description, :monday_start, :monday_capacity, :tuesday_start, :tuesday_capacity, :wednesday_start, :wednesday_capacity, :thursday_start, :thursday_capacity, :friday_start, :friday_capacity, :saturday_start, :saturday_capacity, :sunday_start, :sunday_capacity]
      validate present(:name)
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
      accept [:name, :description, :monday_start, :monday_capacity, :tuesday_start, :tuesday_capacity, :wednesday_start, :wednesday_capacity, :thursday_start, :thursday_capacity, :friday_start, :friday_capacity, :saturday_start, :saturday_capacity, :sunday_start, :sunday_capacity]
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

end
