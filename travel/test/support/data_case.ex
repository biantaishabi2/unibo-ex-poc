defmodule Travel.DataCase do
  @moduledoc """
  Travel 独立项目的数据层测试支撑。
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      alias Travel.Repo

      import Ecto
      import Ecto.Changeset
      import Ecto.Query
      import Travel.DataCase
    end
  end

  setup tags do
    Travel.DataCase.setup_sandbox(tags)
    :ok
  end

  @doc """
  根据测试标签初始化 SQL sandbox。
  """
  def setup_sandbox(tags) do
    pid = Ecto.Adapters.SQL.Sandbox.start_owner!(Travel.Repo, shared: not tags[:async])
    on_exit(fn -> Ecto.Adapters.SQL.Sandbox.stop_owner(pid) end)
  end

  @doc """
  把 changeset 错误转成便于断言的 map。
  """
  def errors_on(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {message, opts} ->
      Regex.replace(~r"%{(\w+)}", message, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
