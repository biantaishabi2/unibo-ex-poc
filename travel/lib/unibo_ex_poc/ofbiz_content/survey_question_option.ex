defmodule UniboExPoc.Ofbiz.Content.SurveyQuestionOption do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Ofbiz.Content,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshPaperTrail.Resource, AshArchival.Resource]

  postgres do
    table "content_survey_question_options"
    repo UniboExPoc.Repo
  end

  graphql do
    type :content_survey_question_option

    queries do
      get :get_content_survey_question_option, :read
      list :list_content_survey_question_options, :read
    end

    mutations do
      create :create_content_survey_question_option, :create
      update :update_content_survey_question_option, :update
      destroy :delete_content_survey_question_option, :destroy
    end

  end

  attributes do
    attribute :survey_option_seq_id, :string do
      allow_nil? false
      primary_key? true
      public? true
    end
    attribute :description, :string, public?: true
    attribute :sequence_num, :integer, public?: true
    attribute :amount_base, :decimal, public?: true
    attribute :amount_base_uom_id, :string, public?: true
    attribute :weight_factor, :float, public?: true
    attribute :duration, :integer, public?: true
    attribute :duration_uom_id, :string, public?: true
    attribute :archived_at, :utc_datetime_usec, allow_nil?: true, public?: false
  end

  relationships do
    belongs_to :survey_question, UniboExPoc.Ofbiz.Content.SurveyQuestion do
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
