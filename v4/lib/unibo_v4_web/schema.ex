defmodule UniboV4Web.Schema do
  use Absinthe.Schema

  use AshGraphql,
    domains: [
      UniboV4.Accounting,
      UniboV4.Analytic,
      UniboV4.Approvals,
      UniboV4.Barcode,
      UniboV4.Blog,
      UniboV4.CRM,
      UniboV4.Calendar,
      UniboV4.Communication,
      UniboV4.Currency,
      UniboV4.DataRecycle,
      UniboV4.Delivery,
      UniboV4.Documents,
      UniboV4.ELearning,
      UniboV4.Ecommerce,
      UniboV4.Events,
      UniboV4.Expenses,
      UniboV4.Fleet,
      UniboV4.Forum,
      UniboV4.Gamification,
      UniboV4.HR,
      UniboV4.Helpdesk,
      UniboV4.Inventory,
      UniboV4.IoT,
      UniboV4.Knowledge,
      UniboV4.LiveChat,
      UniboV4.Loyalty,
      UniboV4.Lunch,
      UniboV4.Maintenance,
      UniboV4.Manufacturing,
      UniboV4.Marketing,
      UniboV4.Membership,
      UniboV4.PLM,
      UniboV4.POS,
      UniboV4.Payment,
      UniboV4.Project,
      UniboV4.Purchasing,
      UniboV4.Quality,
      UniboV4.Rating,
      UniboV4.Rental,
      UniboV4.Repair,
      UniboV4.Sales,
      UniboV4.Sign,
      UniboV4.Spreadsheet,
      UniboV4.Studio,
      UniboV4.Subscriptions,
      UniboV4.Survey,
      UniboV4.Uom,
    ]

  query do
  end

  mutation do
  end
end
