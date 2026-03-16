defmodule UniboExPocWeb.Live.TravelPageHostRuntime do
  @moduledoc """
  Travel 页面宿主运行时适配层。
  """

  @default_pages_dir Path.join(
                       :code.priv_dir(:travel),
                       "static/travel_pages/travel"
                     )

  @default_assigns %{
    editing: false,
    filter: %{sort_by: "", area: "", price_star: "", policy_compliant: "", agreement_hotel: "",
              airline: "", cabin_class: "", departure_airport: "", arrival_airport: "",
              departure_station: "", arrival_station: "", train_type: "",
              checkin_date: "", checkout_date: ""},
    flight_offer: %{departure_airport_code: "", arrival_airport_code: "", departure_at: "",
                    arrival_at: "", flight_no: "", cabin_class: "", fare_family: "",
                    listed_price: "0", settlement_price: "0", currency: "CNY",
                    seats_available: 0, baggage_policy: "", refund_change_policy: "",
                    flight_offer_lifecycle: "", orders: []},
    has_points_deduction: false,
    hotel: %{hotel_name: "", hotel_star: "", address: "", score: "", score_label: "",
             cover_image: "", exterior_image: "", dining_image: "", room_image: ""},
    is_flight_order: false,
    is_hotel_order: false,
    is_train_order: false,
    offer: %{currency: "CNY", total_price: "0", train_no: "", train_type_label: "",
             departure_station_name: "", arrival_station_name: "", departure_time: "",
             arrival_time: "", duration_label: "", date_label: "", seat_options: []},
    offers: [],
    offers_empty: true,
    order: %{order_no: "", status: "", currency: "CNY", total_amount: "0",
             payable_amount: "0", points_deduction_amount: "0", product_type: "",
             traveler_count: 0, ticket_passenger_infos: [], seat_selection_snapshot: nil,
             payment: nil, flight_offer: nil, hotel_offer: nil, train_offer: nil},
    order_booking_success: false,
    order_cancelled_or_failed: false,
    order_pending: false,
    orders: [],
    orders_empty: true,
    order_status_booked_or_completed: false,
    order_status_completed: false,
    order_status_failed: false,
    page_title: "",
    payment_completed: false,
    payment_failed: false,
    payment_pending: false,
    pricing_rules: [],
    record: %{},
    rows: [],
    rows_empty: true,
    search: %{keyword: "", checkin_date: "", checkout_date: "", date_range: [], route_label: ""},
    trains: %{items: [], total_count: 0},
    travelers: %{items: []},
    travelers_empty: true,
    flights: %{items: [], total_count: 0},
    hotels: %{items: [], total_count: 0},
    form: %{contact_name: "", contact_phone: "", contact_email: "",
            payment_method: "", room_count: "", seat_preference: ""},
    policy: %{exceeded: false}
  }

  def default_assigns, do: @default_assigns

  def runtime_mode, do: :mock

  def page_backend, do: nil

  def pages_dir do
    Application.get_env(:travel, :travel_pages_dir, @default_pages_dir)
  end

  def load_page(page, _params, _runtime_mode, _backend) when is_binary(page) do
    case page_template(page) do
      {:ok, path, content} ->
        page_data =
          @default_assigns
          |> Map.merge(load_status_defaults(path))
          |> Map.put(:page_title, page)
          |> Map.merge(load_mock_data(path))

        {:ok, %{path: path, content: content, page_data: page_data}}

      {:error, _reason} = error ->
        error
    end
  end

  def load_page(_page, _params, _runtime_mode, _backend), do: {:error, "页面不存在"}

  def list_pages do
    if File.dir?(pages_dir()) do
      pages_dir()
      |> File.ls!()
      |> Enum.filter(&String.ends_with?(&1, ".heex"))
      |> Enum.map(fn file ->
        name =
          file
          |> String.replace_suffix(".expanded.generated.heex", "")
          |> String.replace_suffix(".generated.heex", "")
          |> String.replace_suffix(".heex", "")

        %{name: name, file: file, route: "/travel/#{name}"}
      end)
      |> Enum.sort_by(& &1.name)
      |> Enum.uniq_by(& &1.name)
    else
      []
    end
  end

  def deep_atomize_keys(value) when is_map(value) do
    Enum.reduce(value, %{}, fn {key, val}, acc ->
      atom_key = if is_binary(key), do: String.to_atom(key), else: key
      Map.put(acc, atom_key, deep_atomize_keys(val))
    end)
  end

  def deep_atomize_keys(value) when is_list(value), do: Enum.map(value, &deep_atomize_keys/1)
  def deep_atomize_keys(value), do: value

  defp page_template(page) do
    candidates = [
      Path.join(pages_dir(), "#{page}.expanded.generated.heex"),
      Path.join(pages_dir(), "#{page}.generated.heex"),
      Path.join(pages_dir(), "#{page}.heex")
    ]

    case Enum.find(candidates, &File.exists?/1) do
      nil -> {:error, "页面不存在: #{page}"}
      path -> {:ok, path, File.read!(path)}
    end
  end

  defp load_mock_data(heex_path) do
    [
      String.replace_suffix(heex_path, ".expanded.generated.heex", ".expanded.mock.json"),
      String.replace_suffix(heex_path, ".generated.heex", ".mock.json"),
      String.replace_suffix(heex_path, ".heex", ".mock.json")
    ]
    |> Enum.uniq()
    |> Enum.find_value(%{}, fn path ->
      if File.exists?(path) do
        case File.read(path) do
          {:ok, json} ->
            case Jason.decode(json) do
              {:ok, data} when is_map(data) -> deep_atomize_keys(data)
              _ -> nil
            end
          _ -> nil
        end
      end
    end)
  end

  defp load_status_defaults(heex_path) do
    status_path = String.replace_suffix(heex_path, ".generated.heex", ".status.schema.v1.json")

    if File.exists?(status_path) do
      case File.read(status_path) do
        {:ok, json} ->
          case Jason.decode(json) do
            {:ok, %{"defaults" => defaults}} when is_map(defaults) ->
              deep_atomize_keys(defaults)
            {:ok, %{"state_schema" => %{"defaults" => defaults}}} when is_map(defaults) ->
              deep_atomize_keys(defaults)
            _ -> %{}
          end
        _ -> %{}
      end
    else
      %{}
    end
  end
end
