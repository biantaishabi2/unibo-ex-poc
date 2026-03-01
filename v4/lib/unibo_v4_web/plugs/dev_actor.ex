defmodule UniboV4Web.Plugs.DevActor do
  @moduledoc """
  开发环境默认 actor — 查找已有的测试用户 ID，
  然后用 %{id: user_id} map 作为 actor。
  Ash 的 relate_actor 只需要 actor 有 :id 字段。
  """
  def init(opts), do: opts

  def call(conn, _opts) do
    actor = get_dev_actor()
    Absinthe.Plug.put_options(conn, context: %{actor: actor})
  end

  defp get_dev_actor do
    case Process.get(:dev_actor) do
      nil ->
        actor = find_any_user_id()
        Process.put(:dev_actor, actor)
        actor
      actor ->
        actor
    end
  end

  defp find_any_user_id do
    # 直接查 DB 获取任意一个用户 ID
    tables = ["sales_users", "accounting_users", "purchasing_users"]

    Enum.find_value(tables, fn table ->
      case UniboV4.Repo.query("SELECT id FROM #{table} LIMIT 1") do
        {:ok, %{rows: [[id]]}} -> %{id: id}
        _ -> nil
      end
    end)
  rescue
    _ -> nil
  end
end
