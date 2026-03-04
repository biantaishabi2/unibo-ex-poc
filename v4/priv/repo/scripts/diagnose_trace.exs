# 诊断 Unknown error 的 stacktrace
alias UniboBddRuntime.DataFactory

resources = [
  {UniboV4.Forum.Post, :create},
  {UniboV4.Sales.SalesOrder, :create},
  {UniboV4.Purchasing.PurchaseOrder, :create},
  {UniboV4.Rental.RentalOrder, :create},
]

Enum.each(resources, fn {res, act} ->
  short = inspect(res) |> String.replace("UniboV4.", "")
  IO.puts("\n=== #{short} (#{act}) ===")

  # 尝试直接创建，跳过 DataFactory
  domain = Ash.Resource.Info.domain(res)
  action = Ash.Resource.Info.action(res, act)

  # 用最简单的 attrs 试
  try do
    cs = Ash.Changeset.for_create(res, act, %{}, domain: domain, authorize?: false)
    case Ash.create(cs) do
      {:ok, r} -> IO.puts("OK direct (authorize?:false)")
      {:error, err} ->
        IO.puts("FAIL direct: #{inspect(err) |> String.slice(0, 1000)}")
    end
  rescue
    e ->
      IO.puts("CRASH direct: #{inspect(e) |> String.slice(0, 500)}")
      IO.puts("TRACE:")
      __STACKTRACE__ |> Enum.take(8) |> Enum.each(&IO.puts("  #{inspect(&1)}"))
  end
end)
