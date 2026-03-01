defmodule UniboV4Web.Plugs.LoadLocale do
  @moduledoc """
  从请求头提取语言设置，注入到 Ash actor context 中。

  支持两种方式传递 locale:
  1. Header: x-locale（优先）
  2. Header: Accept-Language（回退）

  默认语言：zh-CN
  """
  @behaviour Plug

  @default_locale "zh-CN"

  @impl true
  def init(opts), do: opts

  @impl true
  def call(conn, _opts) do
    locale = extract_locale(conn) || @default_locale

    # 注入到 Ash actor context（在 LoadActor 之后执行）
    actor = Ash.PlugHelpers.get_actor(conn) || %{}
    updated_actor = Map.put(actor, :locale, locale)
    Ash.PlugHelpers.set_actor(conn, updated_actor)
  end

  defp extract_locale(conn) do
    # 优先 x-locale header，其次 Accept-Language
    case Plug.Conn.get_req_header(conn, "x-locale") do
      [locale | _] -> locale
      _ -> parse_accept_language(conn)
    end
  end

  defp parse_accept_language(conn) do
    case Plug.Conn.get_req_header(conn, "accept-language") do
      [header | _] ->
        header
        |> String.split(",")
        |> List.first()
        |> String.split(";")
        |> List.first()
        |> String.trim()

      _ ->
        nil
    end
  end
end
