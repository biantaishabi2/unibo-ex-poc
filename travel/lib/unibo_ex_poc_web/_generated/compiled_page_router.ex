defmodule UniboExPocWeb.Generated.CompiledPageRouter do
  @moduledoc """
  编译直出页面路由宏（由 UniBO 自动生成）。
  """

  defmacro compiled_page_routes do
    quote do
      scope "/" do
        pipe_through :browser
        live "/pages/travel/travel_order/new", UniboExPocWeb.Pages.Travel.TravelOrderDetailLive, :new
        live "/pages/travel/home", UniboExPocWeb.Pages.Travel.HomeLive, :index
        live "/pages/travel/travel_order/:id", UniboExPocWeb.Pages.Travel.TravelOrderDetailLive, :show
        live "/pages/travel/travel_request", UniboExPocWeb.Pages.Travel.TravelRequestLive, :show
      end
    end
  end
end
