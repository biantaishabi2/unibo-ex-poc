defmodule UniboExPocWeb.Purchasing.OrderLive.Index do
  @moduledoc """
  采购订单 LiveView 页面（列表 + 创建）。
  """
  use UniboExPocWeb, :live_view

  alias UniboExPoc.Purchasing.{Order, Party}

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "采购订单")
     |> assign(:orders, list_orders())
     |> assign(:suppliers, list_suppliers())
     |> assign(:form, order_form(%{}))}
  end

  @impl true
  def handle_event("save", %{"order" => params}, socket) do
    case create_order(params) do
      {:ok, _order} ->
        {:noreply,
         socket
         |> put_flash(:info, "创建成功")
         |> assign(:orders, list_orders())
         |> assign(:form, order_form(%{}))}

      {:error, error} ->
        {:noreply,
         socket
         |> put_flash(:error, format_error(error))
         |> assign(:form, order_form(params))}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-5xl p-6 space-y-6">
      <h1 class="text-2xl font-semibold">采购订单</h1>

      <div class="rounded-lg border p-4">
        <h2 class="mb-3 text-lg font-medium">创建订单</h2>
        <.form id="order-form" for={@form} phx-submit="save" class="grid gap-3 sm:grid-cols-3">
          <div class="sm:col-span-1">
            <label class="mb-1 block text-sm">订单名称</label>
            <input
              type="text"
              name={@form[:order_name].name}
              value={@form[:order_name].value}
              class="w-full rounded border px-3 py-2"
            />
          </div>

          <div class="sm:col-span-1">
            <label class="mb-1 block text-sm">供应商</label>
            <select
              name={@form[:supplier_id].name}
              value={@form[:supplier_id].value}
              class="w-full rounded border px-3 py-2"
            >
              <option value="">请选择</option>
              <%= for supplier <- @suppliers do %>
                <option value={supplier.id}>{supplier.name}</option>
              <% end %>
            </select>
          </div>

          <div class="sm:col-span-1 flex items-end">
            <button type="submit" class="rounded bg-black px-4 py-2 text-white">创建</button>
          </div>
        </.form>
      </div>

      <div class="rounded-lg border p-4">
        <h2 class="mb-3 text-lg font-medium">订单列表</h2>
        <table class="w-full text-left text-sm">
          <thead>
            <tr class="border-b">
              <th class="py-2">订单号</th>
              <th class="py-2">名称</th>
              <th class="py-2">供应商</th>
              <th class="py-2">状态</th>
            </tr>
          </thead>
          <tbody>
            <%= for order <- @orders do %>
              <tr class="border-b">
                <td class="py-2">{order.id}</td>
                <td class="py-2">{order.order_name}</td>
                <td class="py-2">{order.supplier && order.supplier.name}</td>
                <td class="py-2">{order.status}</td>
              </tr>
            <% end %>
          </tbody>
        </table>
      </div>
    </div>
    """
  end

  defp create_order(%{"supplier_id" => supplier_id} = _params) when supplier_id in [nil, ""] do
    {:error, %{message: "必须选择供应商"}}
  end

  defp create_order(params) do
    attrs = %{
      order_name: blank_to_nil(params["order_name"]),
      supplier_id: params["supplier_id"]
    }

    Order
    |> Ash.Changeset.for_create(:create, attrs)
    |> Ash.create(domain: UniboExPoc.Purchasing)
  end

  defp order_form(params) do
    to_form(
      %{
        "order_name" => params["order_name"] || "",
        "supplier_id" => params["supplier_id"] || ""
      },
      as: :order
    )
  end

  defp list_orders do
    Order
    |> Ash.Query.for_read(:read)
    |> Ash.Query.load(:supplier)
    |> Ash.read!(domain: UniboExPoc.Purchasing)
  end

  defp list_suppliers do
    Party
    |> Ash.Query.for_read(:read)
    |> Ash.read!(domain: UniboExPoc.Purchasing)
  end

  defp blank_to_nil(nil), do: nil
  defp blank_to_nil(""), do: nil
  defp blank_to_nil(value), do: value

  defp format_error(%{message: message}) when is_binary(message), do: message
  defp format_error(%Ash.Error.Invalid{} = error), do: Exception.message(error)
  defp format_error(error), do: inspect(error)
end
