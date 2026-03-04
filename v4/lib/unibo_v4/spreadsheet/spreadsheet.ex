defmodule UniboV4.Spreadsheet do
  use Ash.Domain

  resources do
    resource UniboV4.Spreadsheet.SpreadsheetDocument
    resource UniboV4.Spreadsheet.DataSource
    resource UniboV4.Spreadsheet.Revision
    resource UniboV4.Spreadsheet.GlobalFilter
    resource UniboV4.Spreadsheet.User
  end
end
