defmodule UniboV4.Project.PlanningSlotTemplate do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Project,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  postgres do
    table "project_planning_slot_templates"
    repo UniboV4.Repo
  end

  graphql do
    type :project_planning_slot_template

    queries do
      get :get_project_planning_slot_template, :read
      list :list_project_planning_slot_templates, :read
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string, public?: true
  end

  actions do
    defaults [:read, :update]
  end

end
