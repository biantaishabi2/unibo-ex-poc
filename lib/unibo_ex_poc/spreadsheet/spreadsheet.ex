defmodule UniboV4.Spreadsheet do
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
    resource UniboV4.Spreadsheet.SpreadsheetDocument
    resource UniboV4.Spreadsheet.SpreadsheetDocument.Version
    resource UniboV4.Spreadsheet.DataSource
    resource UniboV4.Spreadsheet.DataSource.Version
    resource UniboV4.Spreadsheet.Revision
    resource UniboV4.Spreadsheet.GlobalFilter
    resource UniboV4.Spreadsheet.GlobalFilter.Version
    resource UniboV4.Spreadsheet.Party
  end
end
