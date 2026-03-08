defmodule UniboV4.Ofbiz.Service.JobSandbox do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Ofbiz.Service,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "Job Scheduler Sandbox"
  end

  postgres do
    table "service_job_sandboxes"
    repo UniboV4.Repo
  end

  graphql do
    type :service_job_sandbox

    queries do
      get :get_service_job_sandbox, :read
      list :list_service_job_sandboxs, :read
    end

    mutations do
      create :create_service_job_sandbox, :create
      update :update_service_job_sandbox, :update
      destroy :delete_service_job_sandbox, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :job_id, :string, public?: true
    attribute :job_name, :string, public?: true
    attribute :run_time, :utc_datetime, public?: true
    attribute :run_time_epoch, :integer, public?: true
    attribute :priority, :integer, public?: true
    attribute :pool_id, :string, public?: true
    attribute :status_id, :string, public?: true
    attribute :parent_job_id, :string, public?: true
    attribute :previous_job_id, :string, public?: true
    attribute :service_name, :string, public?: true
    attribute :loader_name, :string, public?: true
    attribute :max_retry, :integer, public?: true
    attribute :current_retry_count, :integer, public?: true
    attribute :auth_user_login_id, :string, public?: true
    attribute :run_as_user, :string, public?: true
    attribute :current_recurrence_count, :integer, public?: true
    attribute :max_recurrence_count, :integer, public?: true
    attribute :run_by_instance_id, :string, public?: true
    attribute :start_date_time, :utc_datetime, public?: true
    attribute :finish_date_time, :utc_datetime, public?: true
    attribute :cancel_date_time, :utc_datetime, public?: true
    attribute :job_result, :string, public?: true
    attribute :recurrence_time_zone, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :recurrence_info, UniboV4.Ofbiz.Service.RecurrenceInfo do
      public? true
    end
    belongs_to :temporal_expression, UniboV4.Ofbiz.Service.TemporalExpression do
      public? true
      source_attribute :temp_expr_id
    end
    belongs_to :runtime_data, UniboV4.Ofbiz.Service.RuntimeData do
      public? true
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
