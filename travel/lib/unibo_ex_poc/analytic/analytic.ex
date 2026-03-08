defmodule UniboExPoc.Analytic do
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
    resource UniboExPoc.Analytic.AnalyticPlan
    resource UniboExPoc.Analytic.AnalyticPlan.Version
    resource UniboExPoc.Analytic.AnalyticAccount
    resource UniboExPoc.Analytic.AnalyticAccount.Version
    resource UniboExPoc.Analytic.AnalyticLine
    resource UniboExPoc.Analytic.AnalyticLine.Version
    resource UniboExPoc.Analytic.AnalyticDistribution
    resource UniboExPoc.Analytic.AnalyticDistribution.Version
    resource UniboExPoc.Analytic.JournalEntryLine
    resource UniboExPoc.Analytic.Currency
    resource UniboExPoc.Analytic.Product
    resource UniboExPoc.Analytic.Employee
    resource UniboExPoc.Analytic.Party
  end
end
