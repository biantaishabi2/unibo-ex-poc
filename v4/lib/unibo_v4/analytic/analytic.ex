defmodule UniboV4.Analytic do
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
    resource UniboV4.Analytic.AnalyticPlan
    resource UniboV4.Analytic.AnalyticAccount
    resource UniboV4.Analytic.AnalyticLine
    resource UniboV4.Analytic.AnalyticDistribution
    resource UniboV4.Analytic.Partner
    resource UniboV4.Analytic.JournalEntryLine
    resource UniboV4.Analytic.Currency
    resource UniboV4.Analytic.Product
    resource UniboV4.Analytic.Employee
    resource UniboV4.Analytic.Company
  end
end
