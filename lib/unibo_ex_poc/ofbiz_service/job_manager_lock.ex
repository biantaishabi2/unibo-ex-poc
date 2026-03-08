defmodule UniboV4.Ofbiz.Service.JobManagerLock do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Ofbiz.Service,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "Lock Job Manager Scheduler"
  end

  postgres do
    table "service_job_manager_locks"
    repo UniboV4.Repo
  end

  graphql do
    type :service_job_manager_lock

    queries do
      get :get_service_job_manager_lock, :read
      list :list_service_job_manager_locks, :read
    end

    mutations do
      create :create_service_job_manager_lock, :create
      update :update_service_job_manager_lock, :update
      destroy :delete_service_job_manager_lock, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :instance_id, :string, public?: true
    attribute :from_date, :utc_datetime, public?: true
    attribute :thru_date, :utc_datetime, public?: true
    attribute :reason_enum_id, :string, public?: true
    attribute :comments, :string, public?: true
    attribute :created_date, :utc_datetime, public?: true
    attribute :created_by_user_login, :string, public?: true
    attribute :last_modified_date, :utc_datetime, public?: true
    attribute :last_modified_by_user_login, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  identities do
    identity :unique_instance_from_date, [:instance_id, :from_date]
  end

  paper_trail do
    change_tracking_mode :full_diff
    store_action_name? true
    ignore_attributes [:inserted_at, :updated_at]
  end

  archive do
  end

end
