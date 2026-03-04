# 诊断 "Unknown Error" 失败的资源，捕获完整异常和堆栈
alias UniboBddRuntime.DataFactory

resources = [
  UniboV4.Rental.RentalOrder,
  UniboV4.Documents.Document,
  UniboV4.Documents.Share,
  UniboV4.Sales.SalesOrder,
  UniboV4.Knowledge.ArticleMember,
  UniboV4.Knowledge.ArticleVersion,
  UniboV4.Knowledge.Favorite,
  UniboV4.Forum.Post,
  UniboV4.Forum.Vote,
  UniboV4.Purchasing.PurchaseOrder
]

Enum.each(resources, fn resource ->
  short_name = resource |> Module.split() |> Enum.drop(1) |> Enum.join(".")
  separator = String.duplicate("=", 60)
  IO.puts("\n#{separator}")
  IO.puts("Resource: #{short_name}")
  IO.puts(separator)

  create_action = DataFactory.find_create_action(resource)

  if is_nil(create_action) do
    IO.puts("  No create action found!")
  else
    IO.puts("  Create action: #{create_action.name}")

    try do
      _record = DataFactory.create_record!(resource, create_action.name)
      IO.puts("  Result: SUCCESS")
    rescue
      e ->
        stacktrace = __STACKTRACE__
        exception_type = e.__struct__ |> inspect()
        msg = Exception.message(e) |> String.slice(0, 500)

        IO.puts("  Exception type: #{exception_type}")
        IO.puts("  Message (up to 500 chars):")
        IO.puts("    #{msg}")
        IO.puts("  Stacktrace (first 3 lines):")

        stacktrace
        |> Enum.take(3)
        |> Enum.each(fn entry ->
          IO.puts("    #{Exception.format_stacktrace_entry(entry)}")
        end)
    end
  end
end)

IO.puts("\nDone.")
