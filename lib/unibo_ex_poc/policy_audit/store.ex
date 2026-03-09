defmodule UniboExPoc.PolicyAudit.Store do
  @moduledoc """
  权限审计内存存储（ETS）。
  """

  use GenServer

  @table __MODULE__
  @app :unibo_ex_poc
  @default_max_entries 20_000

  def start_link(_opts), do: GenServer.start_link(__MODULE__, %{}, name: __MODULE__)

  def write(entry) when is_map(entry), do: GenServer.cast(__MODULE__, {:write, entry})

  def list(filters \\ %{}), do: GenServer.call(__MODULE__, {:list, filters})

  @impl true
  def init(_state) do
    :ets.new(@table, [
      :ordered_set,
      :public,
      :named_table,
      read_concurrency: true,
      write_concurrency: true
    ])

    {:ok, %{seq: 0}}
  end

  @impl true
  def handle_cast({:write, entry}, state) do
    seq = state.seq + 1
    :ets.insert(@table, {seq, entry})
    trim_if_needed()
    {:noreply, %{state | seq: seq}}
  end

  @impl true
  def handle_call({:list, filters}, _from, state) do
    entries =
      @table
      |> :ets.tab2list()
      |> Enum.sort_by(fn {seq, _} -> seq end, :desc)
      |> Enum.map(fn {_, entry} -> entry end)
      |> Enum.filter(&match_filters?(&1, filters))

    {:reply, {:ok, entries}, state}
  end

  defp trim_if_needed do
    max_entries =
      Application.get_env(@app, UniboExPoc.PolicyAudit.Store, [])
      |> Keyword.get(:max_entries, @default_max_entries)

    case :ets.info(@table, :size) do
      size when is_integer(size) and size > max_entries ->
        trim_count = size - max_entries
        Enum.each(1..trim_count, fn _ -> delete_oldest() end)

      _ ->
        :ok
    end
  end

  defp delete_oldest do
    case :ets.first(@table) do
      :"$end_of_table" -> :ok
      key -> :ets.delete(@table, key)
    end
  end

  defp match_filters?(entry, filters) do
    actor_filter = Map.get(filters, :actor_id) || Map.get(filters, "actor_id")
    resource_filter = Map.get(filters, :resource) || Map.get(filters, "resource")
    result_filter = Map.get(filters, :result) || Map.get(filters, "result")
    since_filter = Map.get(filters, :since) || Map.get(filters, "since")
    until_filter = Map.get(filters, :until) || Map.get(filters, "until")

    match_actor?(entry, actor_filter) and
      match_resource?(entry, resource_filter) and
      match_result?(entry, result_filter) and
      match_since?(entry, since_filter) and
      match_until?(entry, until_filter)
  end

  defp match_actor?(_entry, nil), do: true
  defp match_actor?(entry, actor_id), do: to_string(Map.get(entry, :actor_id)) == to_string(actor_id)

  defp match_resource?(_entry, nil), do: true
  defp match_resource?(entry, resource), do: to_string(Map.get(entry, :resource)) == to_string(resource)

  defp match_result?(_entry, nil), do: true
  defp match_result?(entry, result), do: to_string(Map.get(entry, :result)) == to_string(result)

  defp match_since?(_entry, nil), do: true
  defp match_since?(entry, since_val) do
    with {:ok, entry_dt} <- to_datetime(Map.get(entry, :timestamp)),
         {:ok, since_dt} <- to_datetime(since_val) do
      DateTime.compare(entry_dt, since_dt) in [:eq, :gt]
    else
      _ -> false
    end
  end

  defp match_until?(_entry, nil), do: true
  defp match_until?(entry, until_val) do
    with {:ok, entry_dt} <- to_datetime(Map.get(entry, :timestamp)),
         {:ok, until_dt} <- to_datetime(until_val) do
      DateTime.compare(entry_dt, until_dt) in [:eq, :lt]
    else
      _ -> false
    end
  end

  defp to_datetime(%DateTime{} = dt), do: {:ok, dt}
  defp to_datetime(value) when is_binary(value), do: DateTime.from_iso8601(value)
  defp to_datetime(_), do: {:error, :invalid_datetime}
end
