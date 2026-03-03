defmodule UniboV4.Analytic.Analytic do
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
    resource UniboV4.Analytic.Analytic.AnalyticPlan
    resource UniboV4.Analytic.Analytic.AnalyticAccount
    resource UniboV4.Analytic.Analytic.AnalyticLine
    resource UniboV4.Analytic.Analytic.AnalyticDistribution
    resource UniboV4.Analytic.Analytic.Partner
    resource UniboV4.Analytic.Analytic.JournalEntryLine
    resource UniboV4.Analytic.Analytic.Currency
    resource UniboV4.Analytic.Analytic.Product
    resource UniboV4.Analytic.Analytic.Employee
    resource UniboV4.Analytic.Analytic.Company
  end
end
