defmodule UniboExPoc.Survey.QuestionTriggerAnswerLink do
  use Ash.Resource,
    otp_app: :travel,
    domain: UniboExPoc.Survey,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  resource do
    description "题目触发答案关联桥接"
  end

  postgres do
    table "survey_question_trigger_answer_links"
    repo UniboExPoc.Repo
  end

  graphql do
    type :survey_question_trigger_answer_link

    queries do
      get :get_survey_question_trigger_answer_link, :read
      list :list_survey_question_trigger_answer_links, :read
    end

  end

  attributes do
    uuid_primary_key :id
  end

  relationships do
    belongs_to :question, UniboExPoc.Survey.Question do
      public? true
      allow_nil? false
    end
    belongs_to :answer, UniboExPoc.Survey.Answer do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read, :update]
  end

end
