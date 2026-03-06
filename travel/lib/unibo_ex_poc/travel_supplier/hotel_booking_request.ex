defmodule UniboExPoc.TravelSupplier.HotelBookingRequest do
  @moduledoc """
  canonical hotel 下单意图映射后的 supplier request。
  supplier 特有字段只停留在这里。
  """

  alias UniboExPoc.TravelHost.CallerContext

  @enforce_keys [
    :supplier_code,
    :order_no,
    :hotel_code,
    :room_type_code,
    :rate_plan_code,
    :checkin_date,
    :checkout_date,
    :guest_count,
    :contact_name,
    :contact_phone,
    :member_id,
    :shop_id
  ]
  defstruct [
    :supplier_code,
    :order_no,
    :hotel_code,
    :room_type_code,
    :rate_plan_code,
    :checkin_date,
    :checkout_date,
    :guest_count,
    :contact_name,
    :contact_phone,
    :member_id,
    :shop_id,
    supplier_payload: %{}
  ]

  @type t :: %__MODULE__{}

  @spec from_order(map(), CallerContext.t()) :: t()
  def from_order(order_attrs, %CallerContext{} = context) do
    supplier_payload = %{
      supplier_hotel_id: Map.fetch!(order_attrs, :hotel_code),
      room_code: Map.fetch!(order_attrs, :room_type_code),
      rate_plan_code: Map.fetch!(order_attrs, :rate_plan_code),
      guest_count: Map.get(order_attrs, :traveler_count, 1),
      contact: %{
        name: Map.fetch!(order_attrs, :contact_name),
        phone: Map.fetch!(order_attrs, :contact_phone)
      }
    }

    %__MODULE__{
      supplier_code: Map.fetch!(order_attrs, :supplier_code),
      order_no: Map.fetch!(order_attrs, :order_no),
      hotel_code: Map.fetch!(order_attrs, :hotel_code),
      room_type_code: Map.fetch!(order_attrs, :room_type_code),
      rate_plan_code: Map.fetch!(order_attrs, :rate_plan_code),
      checkin_date: Map.fetch!(order_attrs, :checkin_date),
      checkout_date: Map.fetch!(order_attrs, :checkout_date),
      guest_count: Map.get(order_attrs, :traveler_count, 1),
      contact_name: Map.fetch!(order_attrs, :contact_name),
      contact_phone: Map.fetch!(order_attrs, :contact_phone),
      member_id: context.member_id,
      shop_id: context.current_shop_id,
      supplier_payload: supplier_payload
    }
  end
end
