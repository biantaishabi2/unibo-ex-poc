defmodule UniboExPoc.Spreadsheet do
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
    resource UniboExPoc.Spreadsheet.SpreadsheetDocument
    resource UniboExPoc.Spreadsheet.SpreadsheetDocument.Version
    resource UniboExPoc.Spreadsheet.DataSource
    resource UniboExPoc.Spreadsheet.DataSource.Version
    resource UniboExPoc.Spreadsheet.Revision
    resource UniboExPoc.Spreadsheet.GlobalFilter
    resource UniboExPoc.Spreadsheet.GlobalFilter.Version
    resource UniboExPoc.Spreadsheet.Party
  end
end
