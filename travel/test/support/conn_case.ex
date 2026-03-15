defmodule TravelWeb.ConnCase do
  @moduledoc """
  Travel 独立项目的连接测试支撑。
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      @endpoint TravelWeb.Endpoint

      use TravelWeb, :verified_routes

      import Plug.Conn
      import Phoenix.ConnTest
      import TravelWeb.ConnCase
    end
  end

  setup tags do
    Travel.DataCase.setup_sandbox(tags)
    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end
end
