defmodule UniboExPoc.TravelHost.HostConfig do
  @moduledoc """
  宿主对 travel 暴露的配置结果。
  注意这里不是宿主后台原始配置表，只是 sidecar 消费的收口结果。
  """

  defstruct travel_enabled: false,
            entry_visible: false,
            points_enabled: false,
            mixed_payment_enabled: false,
            cash_payment_enabled: true,
            points_exchange_rate: Decimal.new("0"),
            min_points_to_use: 0,
            max_points_deduction_amount: Decimal.new("0"),
            visible_enterprise_ids: [],
            allowed_product_types: [:hotel]

  @type t :: %__MODULE__{}

  @spec new(map()) :: t()
  def new(attrs \\ %{}) do
    %__MODULE__{}
    |> Map.merge(%{
      travel_enabled: Map.get(attrs, :travel_enabled, Map.get(attrs, "travel_enabled", false)),
      entry_visible: Map.get(attrs, :entry_visible, Map.get(attrs, "entry_visible", false)),
      points_enabled: Map.get(attrs, :points_enabled, Map.get(attrs, "points_enabled", false)),
      mixed_payment_enabled: Map.get(attrs, :mixed_payment_enabled, Map.get(attrs, "mixed_payment_enabled", false)),
      cash_payment_enabled: Map.get(attrs, :cash_payment_enabled, Map.get(attrs, "cash_payment_enabled", true)),
      points_exchange_rate: decimal(Map.get(attrs, :points_exchange_rate, Map.get(attrs, "points_exchange_rate", 0))),
      min_points_to_use: integer(Map.get(attrs, :min_points_to_use, Map.get(attrs, "min_points_to_use", 0))),
      max_points_deduction_amount: decimal(Map.get(attrs, :max_points_deduction_amount, Map.get(attrs, "max_points_deduction_amount", 0))),
      visible_enterprise_ids: list(Map.get(attrs, :visible_enterprise_ids, Map.get(attrs, "visible_enterprise_ids", []))),
      allowed_product_types: product_types(Map.get(attrs, :allowed_product_types, Map.get(attrs, "allowed_product_types", [:hotel])))
    })
  end

  def allowed_enterprise?(%__MODULE__{visible_enterprise_ids: []}, _enterprise_id), do: true

  def allowed_enterprise?(%__MODULE__{visible_enterprise_ids: ids}, enterprise_id) do
    to_string(enterprise_id) in Enum.map(ids, &to_string/1)
  end

  def supports_product?(%__MODULE__{allowed_product_types: types}, product_type) do
    normalize_product_type(product_type) in types
  end

  defp decimal(%Decimal{} = value), do: value
  defp decimal(value), do: Decimal.new(to_string(value || 0))

  defp integer(value) when is_integer(value), do: value
  defp integer(value) when is_binary(value), do: String.to_integer(value)
  defp integer(nil), do: 0

  defp list(value) when is_list(value), do: value
  defp list(nil), do: []
  defp list(value), do: [value]

  defp product_types(types) when is_list(types), do: Enum.map(types, &normalize_product_type/1)
  defp product_types(type), do: [normalize_product_type(type)]

  defp normalize_product_type(value) when is_atom(value), do: value
  defp normalize_product_type(value) when is_binary(value), do: String.to_existing_atom(value)
end
