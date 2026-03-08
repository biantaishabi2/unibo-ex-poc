defmodule UniboV4.Ofbiz.Content.SurveyQuestionCategory do
  use Ash.Resource,
    otp_app: :unibo_ex_poc,
    domain: UniboV4.Ofbiz.Content,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "content_survey_question_categories"
    repo UniboV4.Repo
  end

  graphql do
    type :content_survey_question_category

    queries do
      get :get_content_survey_question_category, :read
      list :list_content_survey_question_categorys, :read
    end

    mutations do
      create :create_content_survey_question_category, :create
      update :update_content_survey_question_category, :update
      destroy :delete_content_survey_question_category, :destroy
    end

  end

  attributes do
    attribute :id, :string do
      primary_key? true
      allow_nil? false
      public? true
    end
    attribute :survey_question_category_id, :string, public?: true
    attribute :description, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :parent_survey_question_category, UniboV4.Ofbiz.Content.SurveyQuestionCategory do
      public? true
      source_attribute :parent_category_id
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
