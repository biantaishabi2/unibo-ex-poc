defmodule UniboV4.Ofbiz.Common.NoteData do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Ofbiz.Common,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  resource do
    description "Note Data"
  end

  postgres do
    table "common_note_datas"
    repo UniboV4.Repo
  end

  graphql do
    type :common_note_data

    queries do
      get :get_common_note_data, :read
      list :list_common_note_datas, :read
    end

    mutations do
      create :create_common_note_data, :create
      update :update_common_note_data, :update
      destroy :delete_common_note_data, :destroy
    end

  end

  attributes do
    uuid_primary_key :id
    attribute :note_id, :string, public?: true
    attribute :note_name, :string, public?: true
    attribute :note_info, :string, public?: true
    attribute :note_date_time, :utc_datetime, public?: true
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
