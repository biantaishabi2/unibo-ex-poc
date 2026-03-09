defmodule UniboExPoc.Ofbiz.HumanRes.TrainingRequest do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.HumanRes,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "human_res_training_requests"
    repo UniboExPoc.Repo
  end

  graphql do
    type :human_res_training_request

    queries do
      get :get_human_res_training_request, :read
      list :list_human_res_training_requests, :read
    end

    mutations do
      create :create_human_res_training_request, :create
      update :update_human_res_training_request, :update
      destroy :delete_human_res_training_request, :destroy
    end

  end

  attributes do
    attribute :id, :string do
      primary_key? true
      allow_nil? false
      public? true
    end
    attribute :training_request_id, :string, public?: true
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
