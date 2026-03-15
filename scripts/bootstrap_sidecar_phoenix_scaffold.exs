#!/usr/bin/env elixir

# 这个脚本把 sidecar Phoenix app 的基础 web/test 骨架补齐，
# 避免业务票重复手工补 ErrorHTML / lazy_html / smoke test。

Mix.install([])

defmodule SidecarPhoenixScaffold do
  @template_root Path.expand("../priv/templates/phoenix_sidecar_scaffold", __DIR__)

  @template_mappings [
    {"lib/web/controllers/error_html.ex.eex", "lib/%{web_path}/controllers/error_html.ex"},
    {"lib/web/controllers/error_json.ex.eex", "lib/%{web_path}/controllers/error_json.ex"},
    {"lib/web/controllers/page_controller.ex.eex",
     "lib/%{web_path}/controllers/page_controller.ex"},
    {"lib/web/controllers/page_html.ex.eex", "lib/%{web_path}/controllers/page_html.ex"},
    {"lib/web/controllers/page_html/home.html.heex.eex",
     "lib/%{web_path}/controllers/page_html/home.html.heex"},
    {"test/web/controllers/error_html_test.exs.eex",
     "test/%{web_path}/controllers/error_html_test.exs"},
    {"test/web/controllers/error_json_test.exs.eex",
     "test/%{web_path}/controllers/error_json_test.exs"},
    {"test/web/controllers/page_controller_test.exs.eex",
     "test/%{web_path}/controllers/page_controller_test.exs"},
    {"test/web/live/page_host_smoke_test.exs.eex",
     "test/%{web_path}/live/page_host_smoke_test.exs"}
  ]

  def main(argv) do
    case parse_args(argv) do
      {:ok, options} ->
        apply_scaffold(options)

      {:error, message} ->
        IO.puts(:stderr, message)
        IO.puts(:stderr, usage())
        System.halt(1)
    end
  end

  defp parse_args(argv) do
    {options, _rest, invalid} =
      OptionParser.parse(argv,
        strict: [app_path: :string, app_module: :string, web_module: :string]
      )

    cond do
      invalid != [] ->
        {:error, "存在无法识别的参数: #{inspect(invalid)}"}

      blank?(options[:app_path]) ->
        {:error, "缺少 --app-path"}

      blank?(options[:app_module]) ->
        {:error, "缺少 --app-module"}

      blank?(options[:web_module]) ->
        {:error, "缺少 --web-module"}

      true ->
        {:ok,
         %{
           app_path: Path.expand(options[:app_path]),
           app_module: options[:app_module],
           web_module: options[:web_module],
           web_path: Macro.underscore(options[:web_module])
         }}
    end
  end

  defp apply_scaffold(assigns) do
    Enum.each(@template_mappings, fn {template_path, destination_pattern} ->
      render_template(assigns, template_path, destination_pattern)
    end)

    ensure_lazy_html_dependency(assigns.app_path)
    IO.puts("Scaffold applied to #{assigns.app_path}")
  end

  defp render_template(assigns, template_path, destination_pattern) do
    source = Path.join(@template_root, template_path)

    destination =
      destination_pattern
      |> String.replace("%{web_path}", assigns.web_path)
      |> then(&Path.join(assigns.app_path, &1))

    destination
    |> Path.dirname()
    |> File.mkdir_p!()

    rendered =
      source
      |> File.read!()
      |> EEx.eval_string(app_module: assigns.app_module, web_module: assigns.web_module)

    File.write!(destination, rendered)
  end

  defp ensure_lazy_html_dependency(app_path) do
    mix_file = Path.join(app_path, "mix.exs")
    contents = File.read!(mix_file)

    if String.contains?(contents, "{:lazy_html,") do
      :ok
    else
      updated =
        case Regex.run(~r/(\s*\{:floki,[^\n]+\}\,?\n)/, contents, capture: :all_but_first) do
          [match] ->
            normalized_match =
              if String.ends_with?(String.trim_trailing(match), ",") do
                match
              else
                String.replace(match, ~r/\n$/, ",\n")
              end

            String.replace(
              contents,
              match,
              normalized_match <> "      {:lazy_html, \">= 0.1.0\", only: :test},\n",
              global: false
            )

          _ ->
            raise """
            无法在 #{mix_file} 中定位 floki 依赖，不能安全插入 lazy_html。
            请先确保该 app 已有 `{:floki, ..., only: :test}` 测试依赖。
            """
        end

      File.write!(mix_file, updated)
    end
  end

  defp blank?(value), do: value in [nil, ""]

  defp usage do
    """
    Usage:
      elixir scripts/bootstrap_sidecar_phoenix_scaffold.exs \\
        --app-path hospital_scheduling \\
        --app-module HospitalScheduling \\
        --web-module HospitalSchedulingWeb
    """
  end
end

SidecarPhoenixScaffold.main(System.argv())
