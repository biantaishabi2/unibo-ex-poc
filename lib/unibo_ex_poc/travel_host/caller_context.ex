defmodule UniboExPoc.TravelHost.CallerContext do
  @moduledoc """
  宿主传给 travel sidecar 的统一上下文。
  这里先只定义能力契约，不预设 HTTP 或 RPC。
  """

  @enforce_keys [:user_id, :member_id, :enterprise_id, :current_shop_id, :request_id]
  defstruct [:user_id, :member_id, :enterprise_id, :current_shop_id, :request_id, roles: [], raw: %{}]

  @type t :: %__MODULE__{
          user_id: String.t(),
          member_id: String.t(),
          enterprise_id: String.t(),
          current_shop_id: String.t(),
          request_id: String.t(),
          roles: [String.t()],
          raw: map()
        }

  @spec normalize(map()) :: {:ok, t()} | {:error, atom()}
  def normalize(input) when is_map(input) do
    attrs = %{
      user_id: fetch(input, [:user_id, "user_id", :"x-user-id", "x-user-id"]),
      member_id: fetch(input, [:member_id, "member_id", :"x-member-id", "x-member-id"]),
      enterprise_id: fetch(input, [:enterprise_id, "enterprise_id", :"x-enterprise-id", "x-enterprise-id"]),
      current_shop_id: fetch(input, [:current_shop_id, "current_shop_id", :shop_id, "shop_id", :"x-shop-id", "x-shop-id"]),
      request_id: fetch(input, [:request_id, "request_id", :"x-request-id", "x-request-id"]),
      roles: normalize_roles(fetch(input, [:roles, "roles", :"x-roles", "x-roles"]))
    }

    case missing_required(attrs) do
      [] -> {:ok, struct(__MODULE__, Map.put(attrs, :raw, input))}
      [field | _] -> {:error, {:missing_field, field}}
    end
  end

  def normalize(_), do: {:error, :invalid_context}

  defp fetch(map, [key | rest]) do
    case Map.get(map, key) do
      nil -> fetch(map, rest)
      value -> value
    end
  end

  defp fetch(_map, []), do: nil

  defp normalize_roles(nil), do: []
  defp normalize_roles(list) when is_list(list), do: Enum.map(list, &to_string/1)

  defp normalize_roles(binary) when is_binary(binary) do
    binary
    |> String.split(",", trim: true)
    |> Enum.map(&String.trim/1)
  end

  defp normalize_roles(_), do: []

  defp missing_required(attrs) do
    attrs
    |> Enum.filter(fn {key, value} -> key != :roles and blank?(value) end)
    |> Enum.map(&elem(&1, 0))
  end

  defp blank?(value), do: value in [nil, ""]
end
