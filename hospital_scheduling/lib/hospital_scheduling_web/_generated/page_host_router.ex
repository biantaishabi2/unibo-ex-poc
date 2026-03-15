defmodule HospitalSchedulingWeb.Generated.PageHostRouter do
  @moduledoc """
  通用页面宿主路由宏（由 UniBO 自动生成）。
  """

  defmacro page_host_routes do
    prefix = HospitalSchedulingWeb.Graphql.RuntimeConfig.page_host_prefix()

    quote do
      scope unquote(prefix), HospitalSchedulingWeb.Generated do
        pipe_through :browser
        live "/", PageHostLive, :index
        live "/*route_segments", PageHostLive, :show
      end
    end
  end
end
