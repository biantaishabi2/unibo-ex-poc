defmodule UniboExPocWeb.CoreComponents do
  @moduledoc """
  最小 CoreComponents — 仅提供 flash_group 等基础组件。
  Stitch UI 组件由 StitchUI.* 模块提供。
  """
  use Phoenix.Component

  # flash_group 组件（app layout 需要）
  attr :flash, :map, required: true

  def flash_group(assigns) do
    ~H"""
    <div>
      <%= if info = Phoenix.Flash.get(@flash, :info) do %>
        <div class="bg-green-50 border border-green-200 text-green-800 px-4 py-3 rounded mb-4">
          <%= info %>
        </div>
      <% end %>
      <%= if error = Phoenix.Flash.get(@flash, :error) do %>
        <div class="bg-red-50 border border-red-200 text-red-800 px-4 py-3 rounded mb-4">
          <%= error %>
        </div>
      <% end %>
    </div>
    """
  end
end
