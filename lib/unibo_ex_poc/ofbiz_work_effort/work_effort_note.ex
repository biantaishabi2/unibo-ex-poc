defmodule UniboExPoc.Ofbiz.WorkEffort.WorkEffortNote do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.WorkEffort,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "work_effort_notes"
    repo UniboExPoc.Repo
  end

  graphql do
    type :work_effort_work_effort_note

    queries do
      get :get_work_effort_work_effort_note, :read
      list :list_work_effort_work_effort_notes, :read
    end

    mutations do
      create :create_work_effort_work_effort_note, :create
      update :update_work_effort_work_effort_note, :update
      destroy :delete_work_effort_work_effort_note, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :internal_note, :boolean, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :work_effort, UniboExPoc.Ofbiz.WorkEffort.WorkEffort do
      public? true
      attribute_type :string
    end
    belongs_to :note_data, UniboExPoc.Ofbiz.WorkEffort.NoteData do
      public? true
      source_attribute :note_id
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
