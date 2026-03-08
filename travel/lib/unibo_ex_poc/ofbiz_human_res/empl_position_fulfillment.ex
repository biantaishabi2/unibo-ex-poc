defmodule UniboExPoc.Ofbiz.HumanRes.EmplPositionFulfillment do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.HumanRes,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "human_res_empl_position_fulfillments"
    repo UniboExPoc.Repo
  end

  graphql do
    type :human_res_empl_position_fulfillment

    queries do
      get :get_human_res_empl_position_fulfillment, :read
      list :list_human_res_empl_position_fulfillments, :read
    end

    mutations do
      create :create_human_res_empl_position_fulfillment, :create
      update :update_human_res_empl_position_fulfillment, :update
      destroy :delete_human_res_empl_position_fulfillment, :destroy
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
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :empl_position, UniboExPoc.Ofbiz.HumanRes.EmplPosition do
      public? true
      attribute_type :string
    end
    belongs_to :party, UniboExPoc.Ofbiz.HumanRes.Party do
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
