defmodule UniboV4.ErrorHelpers do
  @moduledoc """
  运行时错误消息翻译辅助模块 — 由 UniBO 编译器自动生成。

  Ash DSL 中 validation 的 message 选项仅接受编译时字面量字符串，
  不支持 `dgettext/3` 等函数调用。因此验证消息的 i18n 通过本模块
  在运行时对已返回的错误进行翻译。

  ## 用法

      # 翻译单条错误消息
      translated = UniboV4.ErrorHelpers.translate_error(error)

      # 翻译 Ash changeset 返回的所有错误
      translated_errors = UniboV4.ErrorHelpers.translate_errors(errors)

      # 在 Phoenix ErrorView / ErrorJSON 中使用
      def render("error.json", %{changeset: changeset}) do
        errors = Ash.Error.to_error_list(changeset)
        %{errors: UniboV4.ErrorHelpers.translate_errors(errors)}
      end
  """

  @doc "翻译单条错误消息字符串"
  def translate_error(%{message: message, vars: vars}) do
    translated = Gettext.dgettext(UniboV4.Gettext, "errors", message)

    Enum.reduce(vars, translated, fn {key, value}, acc ->
      String.replace(acc, "%{#{key}}", to_string(value))
    end)
  end

  def translate_error(%{message: message}) do
    Gettext.dgettext(UniboV4.Gettext, "errors", message)
  end

  def translate_error(message) when is_binary(message) do
    Gettext.dgettext(UniboV4.Gettext, "errors", message)
  end

  def translate_error(other), do: inspect(other)

  @doc "批量翻译错误列表"
  def translate_errors(errors) when is_list(errors) do
    Enum.map(errors, &translate_error/1)
  end
end
