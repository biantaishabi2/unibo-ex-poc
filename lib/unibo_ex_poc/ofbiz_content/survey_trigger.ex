defmodule UniboV4.Ofbiz.Content.SurveyTrigger do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Ofbiz.Content,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "content_survey_triggers"
    repo UniboV4.Repo
  end

  graphql do
    type :content_survey_trigger

    queries do
      get :get_content_survey_trigger, :read
      list :list_content_survey_triggers, :read
    end

    mutations do
      create :create_content_survey_trigger, :create
      update :update_content_survey_trigger, :update
      destroy :delete_content_survey_trigger, :destroy
    end

  end

  attributes do
    attribute :from_date, :utc_datetime do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :thru_date, :utc_datetime, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :survey, UniboV4.Ofbiz.Content.Survey do
      public? true
      attribute_type :string
    end
    belongs_to :survey_appl_type, UniboV4.Ofbiz.Content.SurveyApplType do
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
