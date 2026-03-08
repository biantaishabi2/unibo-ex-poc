defmodule UniboV4.Ofbiz.HumanRes.EmplLeave do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Ofbiz.HumanRes,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "human_res_empl_leaves"
    repo UniboV4.Repo
  end

  graphql do
    type :human_res_empl_leave

    queries do
      get :get_human_res_empl_leave, :read
      list :list_human_res_empl_leaves, :read
    end

    mutations do
      create :create_human_res_empl_leave, :create
      update :update_human_res_empl_leave, :update
      destroy :delete_human_res_empl_leave, :destroy
    end

  end

  attributes do
    attribute :from_date, :utc_datetime do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :thru_date, :utc_datetime, public?: true
    attribute :description, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :party, UniboV4.Ofbiz.HumanRes.Party do
      public? true
      attribute_type :string
    end
    belongs_to :empl_leave_type, UniboV4.Ofbiz.HumanRes.EmplLeaveType do
      public? true
      source_attribute :leave_type_id
      attribute_type :string
    end
    belongs_to :empl_leave_reason_type, UniboV4.Ofbiz.HumanRes.EmplLeaveReasonType do
      public? true
      attribute_type :string
    end
    belongs_to :approver_party, UniboV4.Ofbiz.HumanRes.Party do
      public? true
      attribute_type :string
    end
    belongs_to :status_item, UniboV4.Ofbiz.HumanRes.StatusItem do
      public? true
      source_attribute :leave_status
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
