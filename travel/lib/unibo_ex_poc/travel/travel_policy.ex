defmodule UniboExPoc.Travel.TravelPolicy do
  @moduledoc """
  差旅标准政策 — 占位模块，定义 struct 字段供 PolicyEngine 使用。
  完整 Ash 资源由编译流水线生成（见 #101 的 travel.ubo.yaml）。
  """

  # 最小化 struct 定义，供 PolicyEngine 和测试使用
  defstruct [
    :id,
    :policy_name,
    :product_type,
    :employee_level,
    :city_tier,
    :season,
    :max_amount,
    :cabin_class_limit,
    :hotel_star_limit,
    :exceed_strategy,
    :personal_pay_ratio,
    :is_active,
    :enterprise_id,
    :inserted_at,
    :updated_at
  ]

  @type t :: %__MODULE__{
    id: String.t() | nil,
    policy_name: String.t() | nil,
    product_type: atom() | nil,
    employee_level: String.t() | nil,
    city_tier: String.t() | nil,
    season: String.t() | nil,
    max_amount: integer() | nil,
    cabin_class_limit: String.t() | nil,
    hotel_star_limit: String.t() | nil,
    exceed_strategy: atom() | nil,
    personal_pay_ratio: integer() | nil,
    is_active: boolean(),
    enterprise_id: String.t() | nil,
    inserted_at: DateTime.t() | nil,
    updated_at: DateTime.t() | nil
  }
end
