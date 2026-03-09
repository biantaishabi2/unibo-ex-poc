defmodule UniboExPoc.AsyncRuntime.Store do
  @moduledoc """
  异步任务内存存储（ETS）。

  任务状态机：
  - queued
  - running
  - retry_scheduled
  - succeeded
  - dead_letter
  - cancelled
  """

  use GenServer

  @table __MODULE__
  @states ~w(queued running retry_scheduled succeeded dead_letter cancelled)a

  def start_link(_opts), do: GenServer.start_link(__MODULE__, %{}, name: __MODULE__)

  def put(task) when is_map(task), do: GenServer.call(__MODULE__, {:put, task})
  def fetch(task_id), do: GenServer.call(__MODULE__, {:fetch, task_id})
  def update(task_id, updates) when is_map(updates), do: GenServer.call(__MODULE__, {:update, task_id, updates})
  def find_by_dedup_key(dedup_key), do: GenServer.call(__MODULE__, {:find_by_dedup_key, dedup_key})
  def list(filters \\ %{}), do: GenServer.call(__MODULE__, {:list, filters})
  def count_by_state, do: GenServer.call(__MODULE__, :count_by_state)

  @impl true
  def init(_state) do
    :ets.new(@table, [
      :set,
      :public,
      :named_table,
      read_concurrency: true,
      write_concurrency: true
    ])

    {:ok, %{}}
  end

  @impl true
  def handle_call({:put, task}, _from, state) do
    normalized =
      task
      |> normalize_task()
      |> ensure_state_valid!()

    :ets.insert(@table, {normalized.id, normalized})
    {:reply, {:ok, normalized}, state}
  end

  @impl true
  def handle_call({:fetch, task_id}, _from, state) do
    reply =
      case :ets.lookup(@table, task_id) do
        [{^task_id, task}] -> {:ok, task}
        _ -> {:error, :not_found}
      end

    {:reply, reply, state}
  end

  @impl true
  def handle_call({:update, task_id, updates}, _from, state) do
    reply =
      case :ets.lookup(@table, task_id) do
        [{^task_id, task}] ->
          merged =
            task
            |> Map.merge(atomize_keys(updates))
            |> Map.put(:updated_at, DateTime.utc_now())
            |> ensure_state_valid!()

          :ets.insert(@table, {task_id, merged})
          {:ok, merged}

        _ ->
          {:error, :not_found}
      end

    {:reply, reply, state}
  end

  @impl true
  def handle_call({:find_by_dedup_key, dedup_key}, _from, state) do
    reply =
      @table
      |> :ets.tab2list()
      |> Enum.map(fn {_, task} -> task end)
      |> Enum.find(fn task -> task.dedup_key == dedup_key end)
      |> case do
        nil -> {:error, :not_found}
        task -> {:ok, task}
      end

    {:reply, reply, state}
  end

  @impl true
  def handle_call({:list, filters}, _from, state) do
    items =
      @table
      |> :ets.tab2list()
      |> Enum.map(fn {_, task} -> task end)
      |> Enum.filter(&match_filters?(&1, filters))
      |> Enum.sort_by(& &1.inserted_at, {:desc, DateTime})

    {:reply, {:ok, items}, state}
  end

  @impl true
  def handle_call(:count_by_state, _from, state) do
    counters =
      @states
      |> Enum.map(fn state_name ->
        count =
          @table
          |> :ets.tab2list()
          |> Enum.count(fn {_, task} -> task.state == state_name end)

        {state_name, count}
      end)
      |> Map.new()

    {:reply, counters, state}
  end

  defp normalize_task(task) do
    task = atomize_keys(task)
    now = DateTime.utc_now()

    %{
      id: Map.get(task, :id),
      kind: Map.get(task, :kind, "generic"),
      payload: Map.get(task, :payload, %{}),
      state: Map.get(task, :state, :queued),
      dedup_key: Map.get(task, :dedup_key),
      trace_id: Map.get(task, :trace_id),
      attempt: Map.get(task, :attempt, 0),
      max_attempts: Map.get(task, :max_attempts, 3),
      next_run_at: Map.get(task, :next_run_at),
      result: Map.get(task, :result),
      last_error: Map.get(task, :last_error),
      inserted_at: Map.get(task, :inserted_at, now),
      updated_at: Map.get(task, :updated_at, now)
    }
  end

  defp ensure_state_valid!(task) do
    if task.state in @states do
      task
    else
      raise ArgumentError, "invalid async task state: #{inspect(task.state)}"
    end
  end

  defp atomize_keys(map) when is_map(map) do
    Map.new(map, fn
      {key, value} when is_binary(key) -> {String.to_atom(key), value}
      {key, value} -> {key, value}
    end)
  end

  defp match_filters?(task, filters) do
    state_filter = Map.get(filters, :state) || Map.get(filters, "state")
    trace_filter = Map.get(filters, :trace_id) || Map.get(filters, "trace_id")
    dedup_filter = Map.get(filters, :dedup_key) || Map.get(filters, "dedup_key")

    (is_nil(state_filter) || to_string(task.state) == to_string(state_filter)) and
      (is_nil(trace_filter) || to_string(task.trace_id) == to_string(trace_filter)) and
      (is_nil(dedup_filter) || to_string(task.dedup_key) == to_string(dedup_filter))
  end
end
