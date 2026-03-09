defmodule UniboExPoc.Ofbiz.HumanRes.EmplPositionReportingStruct do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.HumanRes,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "human_res_empl_position_reporting_structs"
    repo UniboExPoc.Repo
  end

  graphql do
    type :human_res_empl_position_reporting_struct

    queries do
      get :get_human_res_empl_position_reporting_struct, :read
      list :list_human_res_empl_position_reporting_structs, :read
    end

    mutations do
      create :create_human_res_empl_position_reporting_struct, :create
      update :update_human_res_empl_position_reporting_struct, :update
      destroy :delete_human_res_empl_position_reporting_struct, :destroy
    end

  end

  attributes do
    attribute :from_date, :utc_datetime do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :thru_date, :utc_datetime, public?: true
    attribute :comments, :string, public?: true
    attribute :primary_flag, :boolean, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :reporting_to_empl_position, UniboExPoc.Ofbiz.HumanRes.EmplPosition do
      public? true
      source_attribute :empl_position_id_reporting_to
      attribute_type :string
    end
    belongs_to :managed_by_empl_position, UniboExPoc.Ofbiz.HumanRes.EmplPosition do
      public? true
      source_attribute :empl_position_id_managed_by
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
