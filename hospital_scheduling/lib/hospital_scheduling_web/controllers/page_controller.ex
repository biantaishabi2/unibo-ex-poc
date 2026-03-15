defmodule HospitalSchedulingWeb.PageController do
  @moduledoc false
  use HospitalSchedulingWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
