defmodule UniboV4.Survey.QuestionTriggerAnswerLink do
  use Ash.Resource,
    otp_app: :unibo_v4,
    domain: UniboV4.Survey,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "survey_question_trigger_answer_links"
    repo UniboV4.Repo
  end

  attributes do
    uuid_primary_key :id
  end

  relationships do
    belongs_to :question, UniboV4.Survey.Question do
      public? true
      allow_nil? false
    end
    belongs_to :answer, UniboV4.Survey.Answer do
      public? true
      allow_nil? false
    end
  end

  actions do
    defaults [:read]
  end

end
