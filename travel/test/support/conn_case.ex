defmodule UniboExPocWeb.ConnCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      @endpoint UniboExPocWeb.Endpoint

      use Phoenix.ConnTest

      alias UniboExPoc.Repo
      import Ecto
      import Ecto.Changeset
      import Ecto.Query
    end
  end

  setup tags do
    pid = Ecto.Adapters.SQL.Sandbox.start_owner!(UniboExPoc.Repo, shared: not tags[:async])

    on_exit(fn ->
      Ecto.Adapters.SQL.Sandbox.stop_owner(pid)
    end)

    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end
end
