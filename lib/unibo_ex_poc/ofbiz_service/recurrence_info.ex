defmodule UniboExPoc.Ofbiz.Service.RecurrenceInfo do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Service,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "Recurrence Info"
  end

  postgres do
    table "service_recurrence_infos"
    repo UniboExPoc.Repo
  end

  graphql do
    type :service_recurrence_info

    queries do
      get :get_service_recurrence_info, :read
      list :list_service_recurrence_infos, :read
    end

    mutations do
      create :create_service_recurrence_info, :create
      update :update_service_recurrence_info, :update
      destroy :delete_service_recurrence_info, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :recurrence_info_id, :string, public?: true
    attribute :start_date_time, :utc_datetime, public?: true
    attribute :exception_date_times, :string, public?: true
    attribute :recurrence_date_times, :string, public?: true
    attribute :recurrence_count, :integer do
      public? true
      description "Not recommended - more than one process could be using this RecurrenceInfo"
    end
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :recurrence_rule, UniboExPoc.Ofbiz.Service.RecurrenceRule do
      public? true
    end
    belongs_to :exception_rule, UniboExPoc.Ofbiz.Service.RecurrenceRule do
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
