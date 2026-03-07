defmodule UniboExPoc.Ofbiz.Content.SurveyQuestion do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboExPoc.Ofbiz.Content,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "content_survey_questions"
    repo UniboExPoc.Repo
  end

  graphql do
    type :content_survey_question

    queries do
      get :get_content_survey_question, :read
      list :list_content_survey_questions, :read
    end

    mutations do
      create :create_content_survey_question, :create
      update :update_content_survey_question, :update
      destroy :delete_content_survey_question, :destroy
    end

  end

  attributes do
    attribute :id, :string do
      primary_key? true
      allow_nil? false
      public? true
    end
    attribute :survey_question_id, :string, public?: true
    attribute :description, :string, public?: true
    attribute :question, :string, public?: true
    attribute :hint, :string, public?: true
    attribute :enum_type_id, :string, public?: true
    attribute :geo_id, :string, public?: true
    attribute :format_string, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :survey_question_type, UniboExPoc.Ofbiz.Content.SurveyQuestionType do
      public? true
      attribute_type :string
    end
    belongs_to :survey_question_category, UniboExPoc.Ofbiz.Content.SurveyQuestionCategory do
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
