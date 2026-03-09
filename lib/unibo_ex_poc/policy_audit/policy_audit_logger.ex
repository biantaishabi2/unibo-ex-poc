defmodule UniboExPoc.PolicyAudit.PolicyAuditLogger do
  @moduledoc """
  权限策略审计记录器。

  说明：
  - 不参与授权决策，仅记录 Ash 权限判定结果；
  - 通过配置开关可整体关闭，避免影响业务链路。
  """

  alias UniboExPoc.PolicyAudit.Store

  @app :unibo_ex_poc
  @default_sample_rate 1.0

  def enabled? do
    Application.get_env(@app, __MODULE__, [])
    |> Keyword.get(:enabled, false)
  end

  def record(attrs) when is_map(attrs) do
    if enabled?() and sampled?() do
      attrs
      |> normalize()
      |> Store.write()
    end

    :ok
  end

  def query(filters \\ %{}), do: Store.list(filters)

  defp normalize(attrs) do
    %{
      timestamp: normalize_timestamp(Map.get(attrs, :timestamp)),
      actor_id: Map.get(attrs, :actor_id),
      resource: Map.get(attrs, :resource),
      action: Map.get(attrs, :action),
      result: normalize_result(Map.get(attrs, :result)),
      policies_evaluated: Map.get(attrs, :policies_evaluated, []),
      metadata: Map.get(attrs, :metadata, %{})
    }
  end

  defp normalize_timestamp(%DateTime{} = dt), do: dt
  defp normalize_timestamp(_), do: DateTime.utc_now()

  defp normalize_result(nil), do: "unknown"
  defp normalize_result(result), do: to_string(result)

  defp sampled? do
    sample_rate =
      Application.get_env(@app, __MODULE__, [])
      |> Keyword.get(:sample_rate, @default_sample_rate)

    cond do
      sample_rate >= 1 -> true
      sample_rate <= 0 -> false
      true -> :rand.uniform() <= sample_rate
    end
  end
end
