defmodule UniboV4.I18n.TranslationCacheNotifier do
  @moduledoc """
  Ash Notifier，监听翻译资源的变更，自动触发 TranslationCache 失效。
  """
  use Ash.Notifier

  alias UniboV4.I18n.TranslationCache

  @impl true
  def notify(%Ash.Notifier.Notification{resource: resource, data: data, action: _action}) do
    # 翻译变更时，失效对应实体的所有翻译缓存
    entity_id = find_entity_id(data)

    if entity_id do
      TranslationCache.invalidate(resource, entity_id)
    end

    :ok
  end

  # 从翻译记录中提取关联实体 ID（外键字段，如 currency_id）
  defp find_entity_id(data) when is_map(data) do
    data
    |> Map.from_struct()
    |> Enum.find_value(fn {key, value} ->
      key_str = to_string(key)

      if key != :id && String.ends_with?(key_str, "_id") && !is_nil(value) do
        value
      end
    end)
  end

  defp find_entity_id(_), do: nil
end
