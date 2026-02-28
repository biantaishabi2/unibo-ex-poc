defmodule UniboV4Web.Schema do
  use Absinthe.Schema

  use AshGraphql,
    domains: [
      UniboV4.Purchasing,
      UniboV4.Sales,
      UniboV4.Accounting,
      UniboV4.Inventory,
      UniboV4.Manufacturing,
      UniboV4.Maintenance,
      UniboV4.CRM,
      UniboV4.POS,
      UniboV4.Expenses,
      UniboV4.HR,
      UniboV4.Project,
      UniboV4.Helpdesk,
      UniboV4.Marketing,
      UniboV4.Ecommerce,
      UniboV4.Communication
    ]

  query do
  end

  mutation do
  end
end
