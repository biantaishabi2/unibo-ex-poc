defmodule UniboExPocWeb.Generated.CompiledPageRouter do
  @moduledoc """
  编译直出页面路由宏（由 UniBO 自动生成）。
  """

  defmacro compiled_page_routes do
    quote do
      scope "/" do
        pipe_through :browser
        live "/pages/travel/travel_airline/new", UniboExPocWeb.Pages.Travel.TravelAirlineDetailLive, :new
        live "/pages/travel/travel_cabin_class/new", UniboExPocWeb.Pages.Travel.TravelCabinClassDetailLive, :new
        live "/pages/travel/travel_change_order/new", UniboExPocWeb.Pages.Travel.TravelChangeOrderDetailLive, :new
        live "/pages/travel/travel_fulfillment/new", UniboExPocWeb.Pages.Travel.TravelFulfillmentDetailLive, :new
        live "/pages/travel/travel_hotel/new", UniboExPocWeb.Pages.Travel.TravelHotelDetailLive, :new
        live "/pages/travel/travel_order/new", UniboExPocWeb.Pages.Travel.TravelOrderDetailLive, :new
        live "/pages/travel/travel_policy/new", UniboExPocWeb.Pages.Travel.TravelPolicyDetailLive, :new
        live "/pages/travel/travel_policy_check/new", UniboExPocWeb.Pages.Travel.TravelPolicyCheckDetailLive, :new
        live "/pages/travel/travel_refund_order/new", UniboExPocWeb.Pages.Travel.TravelRefundOrderDetailLive, :new
        live "/pages/travel/travel_room_type/new", UniboExPocWeb.Pages.Travel.TravelRoomTypeDetailLive, :new
        live "/pages/travel/travel_static_code_mapping/new", UniboExPocWeb.Pages.Travel.TravelStaticCodeMappingDetailLive, :new
        live "/pages/travel/approval_detail", UniboExPocWeb.Pages.Travel.ApprovalDetailLive, :show
        live "/pages/travel/booking_confirmation", UniboExPocWeb.Pages.Travel.BookingConfirmationLive, :show
        live "/pages/travel/change_confirm", UniboExPocWeb.Pages.Travel.ChangeConfirmLive, :show
        live "/pages/travel/change_flight_search", UniboExPocWeb.Pages.Travel.ChangeFlightSearchLive, :index
        live "/pages/travel/flight_booking", UniboExPocWeb.Pages.Travel.FlightBookingLive, :show
        live "/pages/travel/flight_detail", UniboExPocWeb.Pages.Travel.FlightDetailLive, :show
        live "/pages/travel/flight_offer", UniboExPocWeb.Pages.Travel.FlightOfferListLive, :index
        live "/pages/travel/flight_offer_tree", UniboExPocWeb.Pages.Travel.FlightOfferTreeLive, :index
        live "/pages/travel/flight_search_results", UniboExPocWeb.Pages.Travel.FlightSearchResultsLive, :index
        live "/pages/travel/home", UniboExPocWeb.Pages.Travel.HomeLive, :index
        live "/pages/travel/hotel_booking", UniboExPocWeb.Pages.Travel.HotelBookingLive, :show
        live "/pages/travel/hotel_detail", UniboExPocWeb.Pages.Travel.HotelDetailLive, :show
        live "/pages/travel/hotel_offer", UniboExPocWeb.Pages.Travel.HotelOfferListLive, :index
        live "/pages/travel/hotel_search_results", UniboExPocWeb.Pages.Travel.HotelSearchResultsLive, :index
        live "/pages/travel/order_detail", UniboExPocWeb.Pages.Travel.OrderDetailLive, :show
        live "/pages/travel/order_list", UniboExPocWeb.Pages.Travel.OrderListLive, :index
        live "/pages/travel/payment_confirmation", UniboExPocWeb.Pages.Travel.PaymentConfirmationLive, :show
        live "/pages/travel/policy_check_detail", UniboExPocWeb.Pages.Travel.PolicyCheckDetailLive, :show
        live "/pages/travel/refund_apply", UniboExPocWeb.Pages.Travel.RefundApplyLive, :show
        live "/pages/travel/refund_result", UniboExPocWeb.Pages.Travel.RefundResultLive, :show
        live "/pages/travel/train_booking", UniboExPocWeb.Pages.Travel.TrainBookingLive, :show
        live "/pages/travel/train_detail", UniboExPocWeb.Pages.Travel.TrainDetailLive, :show
        live "/pages/travel/train_offer", UniboExPocWeb.Pages.Travel.TrainOfferListLive, :index
        live "/pages/travel/train_search_results", UniboExPocWeb.Pages.Travel.TrainSearchResultsLive, :index
        live "/pages/travel/travel_airline", UniboExPocWeb.Pages.Travel.TravelAirlineListLive, :index
        live "/pages/travel/travel_airline/:id", UniboExPocWeb.Pages.Travel.TravelAirlineDetailLive, :show
        live "/pages/travel/travel_cabin_class", UniboExPocWeb.Pages.Travel.TravelCabinClassListLive, :index
        live "/pages/travel/travel_cabin_class/:id", UniboExPocWeb.Pages.Travel.TravelCabinClassDetailLive, :show
        live "/pages/travel/travel_change_order", UniboExPocWeb.Pages.Travel.TravelChangeOrderListLive, :index
        live "/pages/travel/travel_change_order/:id", UniboExPocWeb.Pages.Travel.TravelChangeOrderDetailLive, :show
        live "/pages/travel/travel_fulfillment", UniboExPocWeb.Pages.Travel.TravelFulfillmentListLive, :index
        live "/pages/travel/travel_fulfillment/:id", UniboExPocWeb.Pages.Travel.TravelFulfillmentDetailLive, :show
        live "/pages/travel/travel_hotel", UniboExPocWeb.Pages.Travel.TravelHotelListLive, :index
        live "/pages/travel/travel_hotel/:id", UniboExPocWeb.Pages.Travel.TravelHotelDetailLive, :show
        live "/pages/travel/travel_order", UniboExPocWeb.Pages.Travel.TravelOrderListLive, :index
        live "/pages/travel/travel_order/:id", UniboExPocWeb.Pages.Travel.TravelOrderDetailLive, :show
        live "/pages/travel/travel_policy", UniboExPocWeb.Pages.Travel.TravelPolicyListLive, :index
        live "/pages/travel/travel_policy/:id", UniboExPocWeb.Pages.Travel.TravelPolicyDetailLive, :show
        live "/pages/travel/travel_policy_check", UniboExPocWeb.Pages.Travel.TravelPolicyCheckListLive, :index
        live "/pages/travel/travel_policy_check/:id", UniboExPocWeb.Pages.Travel.TravelPolicyCheckDetailLive, :show
        live "/pages/travel/travel_refund_order", UniboExPocWeb.Pages.Travel.TravelRefundOrderListLive, :index
        live "/pages/travel/travel_refund_order/:id", UniboExPocWeb.Pages.Travel.TravelRefundOrderDetailLive, :show
        live "/pages/travel/travel_request", UniboExPocWeb.Pages.Travel.TravelRequestLive, :show
        live "/pages/travel/travel_room_type", UniboExPocWeb.Pages.Travel.TravelRoomTypeListLive, :index
        live "/pages/travel/travel_room_type/:id", UniboExPocWeb.Pages.Travel.TravelRoomTypeDetailLive, :show
        live "/pages/travel/travel_static_code_mapping", UniboExPocWeb.Pages.Travel.TravelStaticCodeMappingListLive, :index
        live "/pages/travel/travel_static_code_mapping/:id", UniboExPocWeb.Pages.Travel.TravelStaticCodeMappingDetailLive, :show
        live "/pages/travel/vacation_offer", UniboExPocWeb.Pages.Travel.VacationOfferListLive, :index
      end
    end
  end
end
