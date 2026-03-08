defmodule UniboExPoc.Ofbiz.HumanRes.EmplPosition do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.HumanRes,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "human_res_empl_positions"
    repo UniboExPoc.Repo
  end

  graphql do
    type :human_res_empl_position

    queries do
      get :get_human_res_empl_position, :read
      list :list_human_res_empl_positions, :read
    end

    mutations do
      create :create_human_res_empl_position, :create
      update :update_human_res_empl_position, :update
      destroy :delete_human_res_empl_position, :destroy
    end

  end

  attributes do
    attribute :id, :string do
      primary_key? true
      allow_nil? false
      public? true
    end
    attribute :empl_position_id, :string, public?: true
    attribute :budget_id, :string, public?: true
    attribute :budget_item_seq_id, :string, public?: true
    attribute :estimated_from_date, :utc_datetime, public?: true
    attribute :estimated_thru_date, :utc_datetime, public?: true
    attribute :salary_flag, :boolean, public?: true
    attribute :exempt_flag, :boolean, public?: true
    attribute :fulltime_flag, :boolean, public?: true
    attribute :temporary_flag, :boolean, public?: true
    attribute :actual_from_date, :utc_datetime, public?: true
    attribute :actual_thru_date, :utc_datetime, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :status_item, UniboExPoc.Ofbiz.HumanRes.StatusItem do
      public? true
      source_attribute :status_id
      attribute_type :string
    end
    belongs_to :party, UniboExPoc.Ofbiz.HumanRes.Party do
      public? true
      attribute_type :string
    end
    belongs_to :empl_position_type, UniboExPoc.Ofbiz.HumanRes.EmplPositionType do
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
