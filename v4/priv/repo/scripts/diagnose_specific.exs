# 诊断特定资源的失败原因
alias UniboBddRuntime.DataFactory

resources = [
  {UniboV4.Forum.Post, :create},
  {UniboV4.Forum.Vote, :create},
  {UniboV4.Knowledge.ArticleMember, :create},
  {UniboV4.Knowledge.ArticleVersion, :create},
  {UniboV4.Knowledge.Favorite, :create},
  {UniboV4.Sales.SalesOrder, :create},
  {UniboV4.Purchasing.PurchaseOrder, :create},
  {UniboV4.Rental.RentalOrder, :create},
]

Enum.each(resources, fn {res, act} ->
  short = inspect(res) |> String.replace("UniboV4.", "")
  IO.puts("\n=== #{short} (#{act}) ===")
  try do
    record = DataFactory.create_record!(res, act)
    IO.puts("OK: id=#{inspect(record.id)}")
  rescue
    e ->
      IO.puts("ERROR: #{e.__struct__}")
      IO.puts("MSG: #{Exception.message(e) |> String.slice(0, 1000)}")
      IO.puts("TRACE:")
      __STACKTRACE__ |> Enum.take(5) |> Enum.each(&IO.puts("  #{inspect(&1)}"))
  end
end)
