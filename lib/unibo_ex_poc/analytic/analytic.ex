defmodule UniboV4.Analytic do
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
    resource UniboV4.Analytic.AnalyticPlan
    resource UniboV4.Analytic.AnalyticPlan.Version
    resource UniboV4.Analytic.AnalyticAccount
    resource UniboV4.Analytic.AnalyticAccount.Version
    resource UniboV4.Analytic.AnalyticLine
    resource UniboV4.Analytic.AnalyticLine.Version
    resource UniboV4.Analytic.AnalyticDistribution
    resource UniboV4.Analytic.AnalyticDistribution.Version
    resource UniboV4.Analytic.JournalEntryLine
    resource UniboV4.Analytic.Currency
    resource UniboV4.Analytic.Product
    resource UniboV4.Analytic.Employee
    resource UniboV4.Analytic.Party
  end
end
