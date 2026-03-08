defmodule UniboExPoc.Ofbiz.WorkEffort.ApplicationSandbox do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.WorkEffort,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "work_effort_application_sandboxes"
    repo UniboExPoc.Repo
  end

  graphql do
    type :work_effort_application_sandbox

    queries do
      get :get_work_effort_application_sandbox, :read
      list :list_work_effort_application_sandboxs, :read
    end

    mutations do
      create :create_work_effort_application_sandbox, :create
      update :update_work_effort_application_sandbox, :update
      destroy :delete_work_effort_application_sandbox, :destroy
    end

  end

  attributes do
    attribute :id, :string do
      primary_key? true
      allow_nil? false
      public? true
    end
    attribute :application_id, :string, public?: true
    attribute :work_effort_id, :string, public?: true
    attribute :party_id, :string, public?: true
    attribute :role_type_id, :string, public?: true
    attribute :from_date, :utc_datetime, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :runtime_data, UniboExPoc.Ofbiz.WorkEffort.RuntimeData do
      public? true
      attribute_type :string
    end
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
  end

end
