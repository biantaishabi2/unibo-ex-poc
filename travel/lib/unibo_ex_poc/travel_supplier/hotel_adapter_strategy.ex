defmodule UniboExPoc.TravelSupplier.HotelAdapterStrategy do
  @moduledoc """
  hotel supplier adapter 的重试与轮询策略占位。
  这里只提供配置基线，真实调度在后续实现阶段接入。
  """

  @booking_retry_delays_ms [200, 500, 1_000]
  @status_poll_max_attempts 5
  @status_poll_interval_ms 1_000
  @incremental_sync_window_seconds 60

  @spec booking_retry_delays_ms() :: [pos_integer()]
  def booking_retry_delays_ms, do: @booking_retry_delays_ms

  @spec status_poll_plan() :: %{max_attempts: pos_integer(), interval_ms: pos_integer()}
  def status_poll_plan do
    %{
      max_attempts: @status_poll_max_attempts,
      interval_ms: @status_poll_interval_ms
    }
  end

  @spec incremental_sync_plan() :: %{window_seconds: pos_integer()}
  def incremental_sync_plan do
    %{
      window_seconds: @incremental_sync_window_seconds
    }
  end
end
