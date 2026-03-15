ExUnit.start()

defmodule BootstrapSidecarPhoenixScaffoldTest do
  use ExUnit.Case, async: true

  @script_path Path.expand("../../scripts/bootstrap_sidecar_phoenix_scaffold.exs", __DIR__)

  test "脚本会生成基础 web/test 骨架并补 lazy_html" do
    app_path = build_fixture_app!("demo_app", "DemoApp")

    {output, 0} =
      System.cmd("elixir", [
        @script_path,
        "--app-path",
        app_path,
        "--app-module",
        "DemoApp",
        "--web-module",
        "DemoAppWeb"
      ])

    assert output =~ "Scaffold applied"
    assert File.exists?(Path.join(app_path, "lib/demo_app_web/controllers/error_html.ex"))
    assert File.exists?(Path.join(app_path, "lib/demo_app_web/controllers/error_json.ex"))
    assert File.exists?(Path.join(app_path, "lib/demo_app_web/controllers/page_controller.ex"))
    assert File.exists?(Path.join(app_path, "lib/demo_app_web/controllers/page_html.ex"))

    assert File.exists?(
             Path.join(app_path, "lib/demo_app_web/controllers/page_html/home.html.heex")
           )

    assert File.exists?(Path.join(app_path, "test/demo_app_web/controllers/error_html_test.exs"))
    assert File.exists?(Path.join(app_path, "test/demo_app_web/controllers/error_json_test.exs"))

    assert File.exists?(
             Path.join(app_path, "test/demo_app_web/controllers/page_controller_test.exs")
           )

    assert File.exists?(Path.join(app_path, "test/demo_app_web/live/page_host_smoke_test.exs"))

    mix_contents = File.read!(Path.join(app_path, "mix.exs"))
    assert mix_contents =~ "{:lazy_html, \">= 0.1.0\", only: :test}"

    smoke_contents =
      File.read!(Path.join(app_path, "test/demo_app_web/live/page_host_smoke_test.exs"))

    assert smoke_contents =~ "render_component"
    assert smoke_contents =~ "DemoAppWeb.PageHostSmokeTest"
  end

  test "重复执行不会重复写入 lazy_html 依赖" do
    app_path = build_fixture_app!("repeat_app", "RepeatApp")

    args = [
      @script_path,
      "--app-path",
      app_path,
      "--app-module",
      "RepeatApp",
      "--web-module",
      "RepeatAppWeb"
    ]

    assert {_, 0} = System.cmd("elixir", args)
    assert {_, 0} = System.cmd("elixir", args)

    mix_contents = File.read!(Path.join(app_path, "mix.exs"))

    assert length(Regex.scan(~r/\{:lazy_html, ">= 0\.1\.0", only: :test\}/, mix_contents)) == 1
  end

  defp build_fixture_app!(app_name, app_module) do
    app_path =
      Path.join(
        System.tmp_dir!(),
        "phoenix_sidecar_scaffold_#{app_name}_#{System.unique_integer([:positive])}"
      )

    File.rm_rf!(app_path)

    web_path =
      app_module
      |> Kernel.<>("Web")
      |> Macro.underscore()

    File.mkdir_p!(Path.join(app_path, "lib/#{web_path}/controllers/page_html"))
    File.mkdir_p!(Path.join(app_path, "test/support"))

    File.write!(
      Path.join(app_path, "mix.exs"),
      """
      defmodule #{app_module}.MixProject do
        use Mix.Project

        def project do
          [
            app: :#{app_name},
            version: "0.1.0",
            elixir: "~> 1.14",
            deps: deps()
          ]
        end

        def application do
          [extra_applications: [:logger]]
        end

        defp deps do
          [
            {:phoenix_live_view, "~> 1.0"},
            {:floki, ">= 0.30.0", only: :test}
          ]
        end
      end
      """
    )

    app_path
  end
end
