defmodule UniboExPoc.Survey do
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
    resource UniboExPoc.Survey.Survey
    resource UniboExPoc.Survey.Survey.Version
    resource UniboExPoc.Survey.Question
    resource UniboExPoc.Survey.Question.Version
    resource UniboExPoc.Survey.Answer
    resource UniboExPoc.Survey.Answer.Version
    resource UniboExPoc.Survey.UserInput
    resource UniboExPoc.Survey.UserInput.Version
    resource UniboExPoc.Survey.UserInputLine
    resource UniboExPoc.Survey.UserInputLine.Version
    resource UniboExPoc.Survey.QuestionTriggerAnswerLink
    resource UniboExPoc.Survey.Party
  end
end
