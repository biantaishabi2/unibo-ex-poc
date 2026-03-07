defmodule UniboExPoc.Ofbiz.Content.SurveyMultiResp do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Content,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "content_survey_multi_resps"
    repo UniboExPoc.Repo
  end

  graphql do
    type :content_survey_multi_resp

    queries do
      get :get_content_survey_multi_resp, :read
      list :list_content_survey_multi_resps, :read
    end

    mutations do
      create :create_content_survey_multi_resp, :create
      update :update_content_survey_multi_resp, :update
      destroy :delete_content_survey_multi_resp, :destroy
    end

  end

  attributes do
    attribute :survey_multi_resp_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :multi_resp_title, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :survey, UniboExPoc.Ofbiz.Content.Survey do
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
