defmodule UniboExPocWeb.TravelLive do
  @moduledoc """
  Travel 页面动态渲染 LiveView。
  从 priv/static/travel_pages/ 加载 .generated.heex 文件，
  动态编译并渲染，使用 StitchUI 组件库。
  """
  use UniboExPocWeb, :live_view

  # 导入 Stitch UI 组件
  import StitchUI.Components.Basic, except: [link: 1]
  import StitchUI.Components.Card
  import StitchUI.Components.Hero
  import StitchUI.Components.Feedback
  import StitchUI.Components.Forms
  import StitchUI.Components.Tabs
  import StitchUI.Components.Stepper
  import StitchUI.Components.Timeline
  import StitchUI.Components.Statistic
  import StitchUI.Components.Avatar
  import StitchUI.Components.Accordion
  import StitchUI.Components.Breadcrumb
  import StitchUI.Components.List
  import StitchUI.Components.Table
  import StitchUI.Components.Select
  import StitchUI.Components.Toggle
  import StitchUI.Components.ControlBar
  import StitchUI.Components.Tree
  import StitchUI.Layouts.Core

  # StitchUI 尚无 header 组件，本地补充
  attr :back, :any, default: nil
  attr :title, :string, default: ""
  attr :subtitle, :string, default: nil
  attr :id, :string, default: nil
  attr :rest, :global
  defp header(assigns) do
    ~H"""
    <div class="flex items-center justify-between p-3" id={@id} {@rest}>
      <%= if @back do %>
        <.button variant="ghost" size="sm">← 返回</.button>
      <% end %>
      <div>
        <.text variant="subtitle" as="h2"><%= @title %></.text>
        <%= if @subtitle do %>
          <.text variant="caption" color="muted"><%= @subtitle %></.text>
        <% end %>
      </div>
    </div>
    """
  end

  @pages_dir Application.app_dir(:unibo_ex_poc, "priv/static/travel_pages")

  @impl true
  def mount(%{"page" => page}, _session, socket) do
    socket =
      socket
      |> assign(:page, page)
      |> assign(:error, nil)
      |> assign(:rendered_content, nil)
      |> load_and_render(page)

    {:ok, socket}
  end

  def mount(_params, _session, socket) do
    # 无 page 参数时列出所有可用页面
    pages = list_pages()

    socket =
      socket
      |> assign(:page, nil)
      |> assign(:error, nil)
      |> assign(:rendered_content, nil)
      |> assign(:pages, pages)

    {:ok, socket}
  end

  @impl true
  def handle_params(%{"page" => page}, _uri, socket) do
    socket =
      socket
      |> assign(:page, page)
      |> assign(:error, nil)
      |> load_and_render(page)

    {:noreply, socket}
  end

  def handle_params(_params, _uri, socket) do
    {:noreply, assign(socket, :pages, list_pages())}
  end

  @impl true
  def handle_event(_event, _params, socket) do
    # 捕获所有事件（phx-click 等），暂时不做处理
    {:noreply, socket}
  end

  defp load_and_render(socket, page) do
    file_path = Path.join(@pages_dir, "#{page}.generated.heex")

    cond do
      !File.exists?(file_path) ->
        # 尝试不带 .generated 的文件名
        alt_path = Path.join(@pages_dir, "#{page}.heex")

        if File.exists?(alt_path) do
          compile_heex(socket, File.read!(alt_path), load_mock_data(alt_path))
        else
          assign(socket, :error, "页面不存在: #{page}")
        end

      true ->
        content = File.read!(file_path)
        mock_data = load_mock_data(file_path)
        compile_heex(socket, content, mock_data)
    end
  end

  defp load_mock_data(heex_path) do
    mock_path = String.replace_suffix(heex_path, ".heex", ".mock.json")

    if File.exists?(mock_path) do
      case File.read(mock_path) do
        {:ok, json} ->
          case Jason.decode(json) do
            {:ok, data} when is_map(data) -> deep_atomize_keys(data)
            _ -> %{}
          end

        _ ->
          %{}
      end
    else
      %{}
    end
  end

  # 确保所有 heex 中引用的 assigns 都存在（默认 nil/空）
  # 使用 Map 作为 struct-like 对象，支持点运算符访问
  @default_assigns %{
    editing: false,
    filter: %{sort_by: "", area: "", price_star: "", policy_compliant: "", agreement_hotel: "",
              airline: "", cabin_class: "", departure_airport: "", arrival_airport: "",
              departure_station: "", arrival_station: "", train_type: ""},
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
    record: %{airline_code: "", airline_name: "", arrival_airport_code: "", arrival_at: "",
              arrival_station_code: "", arrival_station_name: "", baggage_policy: "",
              bed_type: "", boarding_status: "", booking_mode: "", booking_rules: "",
              booking_rules_snapshot: "", cabin_class: "", cabin_class_code: "",
              cabin_class_name: "", cabin_rank: "", cancellation_policy: "",
              canonical_entity: "", canonical_id: "", change_result: "",
              change_rules_snapshot: "", change_status: "", checkin_date: "",
              checkout_date: "", city_code: "", confirmation_payload: "",
              contact_name: "", contact_phone: "", currency: "CNY",
              departure_airport_code: "", departure_at: "", departure_city_code: "",
              departure_station_code: "", departure_station_name: "", destination_code: "",
              end_date: "", external_code: "", external_name: "", failure_reason: "",
              fare_family: "", flight_no: "", fulfillment_type: "", guarantee_policy: "",
              host_enterprise_id: "", host_member_id: "", host_shop_id: "",
              hotel_code: "", hotel_name: "", hotel_star: "", iata_code: "",
              icao_code: "", inventory_count: 0, inventory_status: "",
              is_no_seat: false, itinerary_code: "", listed_price: "0",
              object_type: "", order_no: "", original_order_ref: "",
              package_code: "", package_name: "", package_type: "",
              payment_external_ref: "", points_deduction_amount: "0",
              points_to_use: 0, product_type: "", rate_plan_code: "",
              recommended_payment_method: "", refund_change_policy: "",
              refund_rules_snapshot: "", room_type_code: "", room_type_name: "",
              sale_status: "", seat_class: "", seat_code: "", seats_available: 0,
              seat_selection_snapshot: "", settlement_price: "0", start_date: "",
              status: "", supplier_booking_ref: "", supplier_code: "",
              supplier_order_ref: "", tenant_id: "", ticket_passenger_infos: [],
              ticket_refs: [], total_amount: "0", train_no: "", travel_date: "",
              traveler_count: 0, used_at: "", voucher_or_ticket_ref: "",
              waitlist_result: "", waitlist_status: "", waitlist_supported: false},
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

  defp compile_heex(socket, content, mock_data) do
    try do
      module_name = :"Elixir.TravelDynamic.Render#{:erlang.unique_integer([:positive])}"

      module_code = """
      defmodule #{module_name} do
        use Phoenix.Component

        import StitchUI.Components.Basic, except: [link: 1]
        import StitchUI.Components.Card
        import StitchUI.Components.Hero
        import StitchUI.Components.Feedback
        import StitchUI.Components.Forms
        import StitchUI.Components.Tabs
        import StitchUI.Components.Stepper
        import StitchUI.Components.Timeline
        import StitchUI.Components.Statistic
        import StitchUI.Components.Avatar
        import StitchUI.Components.Accordion
        import StitchUI.Components.Breadcrumb
        import StitchUI.Components.List
        import StitchUI.Components.Table
        import StitchUI.Components.Select
        import StitchUI.Components.Toggle
        import StitchUI.Components.ControlBar
        import StitchUI.Components.Tree
        import StitchUI.Layouts.Core

        # StitchUI 尚无 header 组件，本地补充
        attr :back, :any, default: nil
        attr :title, :string, default: ""
        attr :subtitle, :string, default: nil
        attr :id, :string, default: nil
        attr :rest, :global
        def header(assigns) do
          ~H\"\"\"
          <div class="flex items-center justify-between p-3" id={@id} {@rest}>
            <%= if @back do %>
              <.button variant="ghost" size="sm">← 返回</.button>
            <% end %>
            <div>
              <.text variant="subtitle" as="h2"><%= @title %></.text>
              <%= if @subtitle do %>
                <.text variant="caption" color="muted"><%= @subtitle %></.text>
              <% end %>
            </div>
          </div>
          \"\"\"
        end

        def render(assigns) do
          ~H\"\"\"
      #{content}
          \"\"\"
        end
      end
      """

      Code.compile_string(module_code)

      assigns = @default_assigns |> Map.merge(mock_data) |> Map.put(:__changed__, nil)
      result = apply(module_name, :render, [assigns])

      :code.purge(module_name)
      :code.delete(module_name)

      assign(socket, :rendered_content, result)
    rescue
      e ->
        assign(socket, :error, "编译错误: #{Exception.message(e)}")
    end
  end

  defp deep_atomize_keys(value) when is_map(value) do
    Enum.reduce(value, %{}, fn {key, val}, acc ->
      atom_key = if is_binary(key), do: String.to_atom(key), else: key
      Map.put(acc, atom_key, deep_atomize_keys(val))
    end)
  end

  defp deep_atomize_keys(value) when is_list(value), do: Enum.map(value, &deep_atomize_keys/1)
  defp deep_atomize_keys(value), do: value

  defp list_pages do
    @pages_dir
    |> File.ls!()
    |> Enum.filter(&String.ends_with?(&1, ".heex"))
    |> Enum.reject(&String.ends_with?(&1, ".mock.json"))
    |> Enum.map(fn f ->
      name = f |> String.replace_suffix(".generated.heex", "") |> String.replace_suffix(".heex", "")
      %{name: name, file: f}
    end)
    |> Enum.sort_by(& &1.name)
    |> Enum.uniq_by(& &1.name)
  end

  @impl true
  def render(%{page: nil} = assigns) do
    ~H"""
    <div class="min-h-screen bg-gray-50 p-8">
      <h1 class="text-2xl font-bold mb-6">Travel 页面一览</h1>
      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
        <%= for p <- @pages do %>
          <a
            href={"/travel/#{p.name}"}
            class="block p-4 bg-white rounded-lg shadow hover:shadow-md transition-shadow border"
          >
            <div class="font-medium text-blue-600"><%= p.name %></div>
            <div class="text-sm text-gray-500 mt-1"><%= p.file %></div>
          </a>
        <% end %>
      </div>
    </div>
    """
  end

  def render(%{error: error} = assigns) when not is_nil(error) do
    ~H"""
    <div class="flex items-center justify-center min-h-screen">
      <div class="bg-white p-8 rounded-lg shadow-lg max-w-md">
        <h1 class="text-xl font-bold text-red-600 mb-4">渲染错误</h1>
        <p class="text-gray-600 mb-4 whitespace-pre-wrap"><%= @error %></p>
        <a href="/travel" class="text-blue-600 hover:underline">返回页面列表</a>
      </div>
    </div>
    """
  end

  def render(assigns) do
    ~H"""
    <div class="min-h-screen">
      <div class="fixed top-2 right-2 z-50 flex gap-2">
        <a href="/travel" class="bg-black/70 text-white px-3 py-1.5 rounded text-sm hover:bg-black/85">
          ← 列表
        </a>
      </div>
      <%= @rendered_content %>
    </div>
    """
  end
end
