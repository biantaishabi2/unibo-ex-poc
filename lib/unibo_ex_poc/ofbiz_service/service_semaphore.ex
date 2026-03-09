defmodule UniboExPoc.Ofbiz.Service.ServiceSemaphore do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Service,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "Semaphore Lock"
  end

  postgres do
    table "service_semaphores"
    repo UniboExPoc.Repo
  end

  graphql do
    type :service_service_semaphore

    queries do
      get :get_service_service_semaphore, :read
      list :list_service_service_semaphores, :read
    end

    mutations do
      create :create_service_service_semaphore, :create
      update :update_service_service_semaphore, :update
      destroy :delete_service_service_semaphore, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :service_name, :string, public?: true
    attribute :locked_by_instance_id, :string, public?: true
    attribute :lock_thread, :string, public?: true
    attribute :lock_time, :utc_datetime, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
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
