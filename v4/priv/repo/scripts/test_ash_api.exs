# 检查一个失败 resource 的详细错误
UniboV4.Repo.start_link()

resource = UniboV4.Rating.RatingType
domain = Ash.Resource.Info.domain(resource)

case Ash.read(resource, action: :read, domain: domain) do
  {:ok, results} -> IO.puts("READ success: #{length(results)} records")
  {:error, err} -> IO.inspect(err, label: "READ error", limit: :infinity)
end
