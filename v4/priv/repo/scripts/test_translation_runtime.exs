# 翻译运行时端到端测试
# mix run priv/repo/scripts/test_translation_runtime.exs

require Ash.Query

alias UniboV4.Currency.{Currency, CurrencyTranslation}
alias UniboV4.I18n.TranslationCache

IO.puts("=== 翻译运行时端到端测试 ===\n")

# 清理可能存在的测试数据
existing =
  Currency
  |> Ash.Query.filter(code == "TCNY")
  |> Ash.read!()

Enum.each(existing, fn c ->
  # 先删翻译
  CurrencyTranslation
  |> Ash.Query.filter(currency_id == ^c.id)
  |> Ash.read!()
  |> Enum.each(&Ash.destroy!/1)

  Ash.destroy!(c)
end)

# Step 1: 创建测试 Currency
IO.puts("1. 创建测试 Currency TCNY...")
cny = Ash.create!(Currency, %{code: "TCNY", name: "人民币", symbol: "¥"})
IO.puts("   创建成功: #{cny.id}")

# Step 2: 创建英文翻译
IO.puts("2. 创建英文翻译...")
en_trans = Ash.create!(CurrencyTranslation, %{
  currency_id: cny.id,
  locale: "en",
  field_name: "name",
  value: "Chinese Yuan"
})
IO.puts("   英文翻译: #{en_trans.value}")

# Step 3: 创建日文翻译
IO.puts("3. 创建日文翻译...")
ja_trans = Ash.create!(CurrencyTranslation, %{
  currency_id: cny.id,
  locale: "ja",
  field_name: "name",
  value: "中国元"
})
IO.puts("   日文翻译: #{ja_trans.value}")

# Step 4: 创建默认语言翻译（zh-CN）
IO.puts("4. 创建默认语言翻译 zh-CN...")
zh_trans = Ash.create!(CurrencyTranslation, %{
  currency_id: cny.id,
  locale: "zh-CN",
  field_name: "name",
  value: "人民币"
})
IO.puts("   中文翻译: #{zh_trans.value}")

# Step 5: 测试缓存查询
IO.puts("\n5. 测试缓存查询...")

# 英文查询
en_result = TranslationCache.get_translation(CurrencyTranslation, cny.id, "en", "name")
IO.puts("   查询 en: #{inspect(en_result)}")
assert_eq = fn actual, expected, label ->
  if actual == expected do
    IO.puts("   ✅ #{label}: #{inspect(actual)}")
  else
    IO.puts("   ❌ #{label}: 期望 #{inspect(expected)}，实际 #{inspect(actual)}")
    raise "断言失败: #{label}"
  end
end

assert_eq.(en_result, "Chinese Yuan", "英文翻译查询")

# 日文查询
ja_result = TranslationCache.get_translation(CurrencyTranslation, cny.id, "ja", "name")
assert_eq.(ja_result, "中国元", "日文翻译查询")

# Step 6: 测试 fallback（法语不存在，应回退到 zh-CN）
IO.puts("\n6. 测试 locale fallback...")
fr_result = TranslationCache.get_translation(CurrencyTranslation, cny.id, "fr", "name")
assert_eq.(fr_result, "人民币", "法语 fallback 到 zh-CN")

# Step 7: 测试缓存命中（第二次查询应走缓存）
IO.puts("\n7. 测试缓存命中...")
en_cached = TranslationCache.get_translation(CurrencyTranslation, cny.id, "en", "name")
assert_eq.(en_cached, "Chinese Yuan", "缓存命中查询")

# Step 8: 测试缓存失效（更新翻译值）
IO.puts("\n8. 测试缓存失效...")
Ash.update!(en_trans, %{value: "Chinese Yuan (Updated)"})
IO.puts("   已更新英文翻译为 'Chinese Yuan (Updated)'")

# Notifier 应自动失效缓存，再查应返回新值
en_updated = TranslationCache.get_translation(CurrencyTranslation, cny.id, "en", "name")
assert_eq.(en_updated, "Chinese Yuan (Updated)", "缓存失效后查询新值")

# Step 9: 测试 default 参数
IO.puts("\n9. 测试 default 参数...")
missing_result = TranslationCache.get_translation(
  CurrencyTranslation, Ash.UUID.generate(), "xx", "name",
  default: "FALLBACK_DEFAULT"
)
assert_eq.(missing_result, "FALLBACK_DEFAULT", "不存在的翻译返回 default 值")

# Step 10: 测试手动失效
IO.puts("\n10. 测试手动全量失效...")
TranslationCache.invalidate_all()
en_after_flush = TranslationCache.get_translation(CurrencyTranslation, cny.id, "en", "name")
assert_eq.(en_after_flush, "Chinese Yuan (Updated)", "全量失效后重新加载")

# 清理测试数据
IO.puts("\n清理测试数据...")
CurrencyTranslation
|> Ash.Query.filter(currency_id == ^cny.id)
|> Ash.read!()
|> Enum.each(&Ash.destroy!/1)

Ash.destroy!(cny)
TranslationCache.invalidate_all()

IO.puts("\n=== 所有测试通过 ✅ ===")
