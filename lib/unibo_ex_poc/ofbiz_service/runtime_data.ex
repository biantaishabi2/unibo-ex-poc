defmodule UniboV4.Ofbiz.Service.RuntimeData do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Ofbiz.Service,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "Runtime Data"
  end

  postgres do
    table "service_runtime_datas"
    repo UniboV4.Repo
  end

  graphql do
    type :service_runtime_data

    queries do
      get :get_service_runtime_data, :read
      list :list_service_runtime_datas, :read
    end

    mutations do
      create :create_service_runtime_data, :create
      update :update_service_runtime_data, :update
      destroy :delete_service_runtime_data, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :runtime_data_id, :string, public?: true
    attribute :runtime_info, :string, public?: true
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
