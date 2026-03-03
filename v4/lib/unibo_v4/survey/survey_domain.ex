defmodule UniboV4.Survey do
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
    resource UniboV4.Survey.Survey
    resource UniboV4.Survey.Question
    resource UniboV4.Survey.Answer
    resource UniboV4.Survey.UserInput
    resource UniboV4.Survey.UserInputLine
    resource UniboV4.Survey.QuestionTriggerAnswerLink
    resource UniboV4.Survey.Partner
  end
end
