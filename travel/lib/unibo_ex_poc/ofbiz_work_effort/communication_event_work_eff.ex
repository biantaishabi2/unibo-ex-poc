defmodule UniboExPoc.Ofbiz.WorkEffort.CommunicationEventWorkEff do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.WorkEffort,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "work_effort_communication_event_work_effs"
    repo UniboExPoc.Repo
  end

  graphql do
    type :work_effort_communication_event_work_eff

    queries do
      get :get_work_effort_communication_event_work_eff, :read
      list :list_work_effort_communication_event_work_effs, :read
    end

    mutations do
      create :create_work_effort_communication_event_work_eff, :create
      update :update_work_effort_communication_event_work_eff, :update
      destroy :delete_work_effort_communication_event_work_eff, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :description, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :work_effort, UniboExPoc.Ofbiz.WorkEffort.WorkEffort do
      public? true
      attribute_type :string
    end
    belongs_to :communication_event, UniboExPoc.Ofbiz.WorkEffort.CommunicationEvent do
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
