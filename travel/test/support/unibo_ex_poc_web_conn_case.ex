defmodule UniboExPocWeb.ConnCase do
  @moduledoc """
  编译器生成的 GraphQL 测试所需的 ConnCase。
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      @endpoint UniboExPocWeb.Endpoint

      import Plug.Conn
      import Phoenix.ConnTest
    end
  end

  setup tags do
    pid = Ecto.Adapters.SQL.Sandbox.start_owner!(UniboExPoc.Repo, shared: not tags[:async])
    on_exit(fn -> Ecto.Adapters.SQL.Sandbox.stop_owner(pid) end)
    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end
end
