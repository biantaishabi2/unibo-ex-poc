defmodule UniboV4.I18n.TranslationCache do
  @moduledoc """
  ETS 缓存层，缓存翻译数据。
  支持 TTL 过期（10 分钟）、手动失效和 locale fallback。
  """
  use GenServer

  require Ash.Query
  require Logger

  @table :unibo_translation_cache
  @ttl_ms :timer.minutes(10)
  @default_locale "zh-CN"

  # === 公共 API ===

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @doc """
  获取翻译值，缓存未命中时自动从 DB 加载。
  支持 fallback 到默认语言。

  参数：
  - translation_resource: 翻译 Ash Resource 模块（如 CurrencyTranslation）
  - entity_id: 被翻译实体的 ID
  - locale: 目标语言（如 "en"）
  - field_name: 字段名（如 "name"）
  - opts:
    - :default_locale - 默认语言，缺省 "zh-CN"
    - :default - 兜底默认值，缺省 nil
    - :domain - Ash domain 模块
    - :entity_key - 翻译表中外键字段名（如 :currency_id），缺省自动推断
  """
  def get_translation(translation_resource, entity_id, locale, field_name, opts \\ []) do
    default_locale = Keyword.get(opts, :default_locale, @default_locale)
    default_value = Keyword.get(opts, :default)
    cache_key = {translation_resource, entity_id, locale, field_name}

    case lookup(cache_key) do
      {:ok, value} ->
        value

      :miss ->
        value = load_and_cache(translation_resource, entity_id, locale, field_name, opts)

        # fallback 到默认语言
        value =
          if is_nil(value) && locale != default_locale do
            fallback_key = {translation_resource, entity_id, default_locale, field_name}

            case lookup(fallback_key) do
              {:ok, v} -> v
              :miss -> load_and_cache(translation_resource, entity_id, default_locale, field_name, opts)
            end
          else
            value
          end

        value || default_value
    end
  end

  @doc "失效某实体在某翻译 Resource 下的所有翻译缓存"
  def invalidate(translation_resource, entity_id) do
    # 遍历 ETS 表，删除匹配的 key
    :ets.select_delete(@table, [
      {{{translation_resource, entity_id, :_, :_}, :_, :_}, [], [true]}
    ])

    :ok
  end

  @doc "失效某实体 ID 的所有翻译缓存（跨 Resource）"
  def invalidate_entity(entity_id) do
    :ets.select_delete(@table, [
      {{{:_, entity_id, :_, :_}, :_, :_}, [], [true]}
    ])

    :ok
  end

  @doc "全量失效"
  def invalidate_all do
    :ets.delete_all_objects(@table)
    :ok
  end

  # === GenServer 回调 ===

  @impl true
  def init(_opts) do
    table = :ets.new(@table, [:named_table, :set, :public, read_concurrency: true])
    {:ok, %{table: table}}
  end

  # === 内部函数 ===

  defp lookup(cache_key) do
    case :ets.lookup(@table, cache_key) do
      [{^cache_key, value, expires_at}] ->
        now = System.monotonic_time(:millisecond)

        if now < expires_at do
          {:ok, value}
        else
          :ets.delete(@table, cache_key)
          :miss
        end

      [] ->
        :miss
    end
  end

  defp load_and_cache(translation_resource, entity_id, locale, field_name, opts) do
    value = load_from_db(translation_resource, entity_id, locale, field_name, opts)
    cache_key = {translation_resource, entity_id, locale, field_name}
    expires_at = System.monotonic_time(:millisecond) + @ttl_ms
    :ets.insert(@table, {cache_key, value, expires_at})
    value
  end

  defp load_from_db(translation_resource, entity_id, locale, field_name, opts) do
    entity_key = Keyword.get(opts, :entity_key) || infer_entity_key(translation_resource)
    domain = Keyword.get(opts, :domain)

    query =
      translation_resource
      |> Ash.Query.filter(^Ash.Expr.ref(entity_key) == ^entity_id)
      |> Ash.Query.filter(locale == ^locale)
      |> Ash.Query.filter(field_name == ^field_name)
      |> Ash.Query.limit(1)

    read_opts = if domain, do: [domain: domain], else: []

    case Ash.read(query, read_opts) do
      {:ok, [record | _]} -> record.value
      _ -> nil
    end
  end

  # 从翻译 Resource 模块名推断外键字段名
  # 如 UniboV4.Currency.CurrencyTranslation → :currency_id
  defp infer_entity_key(translation_resource) do
    translation_resource
    |> Module.split()
    |> List.last()
    |> String.replace_suffix("Translation", "")
    |> Macro.underscore()
    |> Kernel.<>("_id")
    |> String.to_atom()
  end
end
