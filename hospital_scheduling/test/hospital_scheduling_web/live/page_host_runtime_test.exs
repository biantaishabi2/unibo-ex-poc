defmodule HospitalSchedulingWeb.Live.PageHostRuntimeTest do
  use ExUnit.Case, async: false

  alias HospitalSchedulingWeb.Live.PageHostRuntime

  defmodule EchoBackend do
    def dispatch("__load__", _params, state) do
      {:ok,
       %{
         dto: %{"selection" => Map.get(state, "selection")},
         status: %{},
         effects: [],
         errors: [],
         meta: %{}
       }}
    end
  end

  setup do
    tmp_dir =
      Path.join(
        System.tmp_dir!(),
        "page_host_runtime_test_#{System.unique_integer([:positive])}"
      )

    File.rm_rf(tmp_dir)
    File.mkdir_p!(tmp_dir)

    previous_pages_dir = Application.get_env(:hospital_scheduling, :scheduling_pages_dir)

    on_exit(fn ->
      restore_env(:scheduling_pages_dir, previous_pages_dir)
      File.rm_rf(tmp_dir)
    end)

    Application.put_env(:hospital_scheduling, :scheduling_pages_dir, tmp_dir)

    %{tmp_dir: tmp_dir}
  end

  test "优先使用页面 behavior 里的 backend.load.selection", %{tmp_dir: tmp_dir} do
    write_page!(tmp_dir, "shift_type_list")

    write_status_defaults!(tmp_dir, "shift_type_list", %{
      "rows" => [%{"name" => "placeholder"}]
    })

    write_behavior!(tmp_dir, "shift_type_list", %{
      "backend" => %{
        "load" => %{
          "selection" => "id code name"
        }
      }
    })

    assert {:ok, %{page_data: %{selection: "id code name"}}} =
             PageHostRuntime.load_page("shift_type_list", %{}, :graphql, EchoBackend)
  end

  test "没有显式契约时按本页 status defaults 推导 rows 字段", %{tmp_dir: tmp_dir} do
    write_page!(tmp_dir, "scheduling_period_list")

    write_status_defaults!(tmp_dir, "scheduling_period_list", %{
      "rows" => [
        %{
          "title" => "",
          "department" => %{"name" => ""},
          "state" => ""
        }
      ]
    })

    assert {:ok, %{page_data: %{selection: selection}}} =
             PageHostRuntime.load_page("scheduling_period_list", %{}, :graphql, EchoBackend)

    assert selection =~ "title"
    assert selection =~ "department { name }"
    assert selection =~ "state"
  end

  test "根据页面契约过滤 params", %{tmp_dir: tmp_dir} do
    write_page!(tmp_dir, "requirement_matrix")

    write_behavior!(tmp_dir, "requirement_matrix", %{
      "backend" => %{
        "params" => %{
          "accept" => ["id", "week_offset"]
        }
      }
    })

    assert %{"id" => "p1", "week_offset" => "1"} =
             PageHostRuntime.normalize_page_params("requirement_matrix", %{
               "id" => "p1",
               "week_offset" => "1",
               "unexpected" => "drop"
             })
  end

  test "根据页面契约判断是否支持 reload 消息", %{tmp_dir: tmp_dir} do
    write_page!(tmp_dir, "shift_type_list")

    write_behavior!(tmp_dir, "shift_type_list", %{
      "backend" => %{
        "info" => %{
          "reload_messages" => ["page_host_reload"]
        }
      }
    })

    assert PageHostRuntime.supports_reload?("shift_type_list")
  end

  defp write_page!(tmp_dir, page_id) do
    File.write!(Path.join(tmp_dir, "#{page_id}.expanded.generated.heex"), "<div>#{page_id}</div>")
  end

  defp write_status_defaults!(tmp_dir, page_id, defaults) do
    File.write!(
      Path.join(tmp_dir, "#{page_id}.expanded.status.schema.v1.json"),
      Jason.encode!(%{"defaults" => defaults})
    )
  end

  defp write_behavior!(tmp_dir, page_id, payload) do
    File.write!(
      Path.join(tmp_dir, "#{page_id}.expanded.behavior.v1.json"),
      Jason.encode!(payload)
    )
  end

  defp restore_env(key, nil), do: Application.delete_env(:hospital_scheduling, key)
  defp restore_env(key, value), do: Application.put_env(:hospital_scheduling, key, value)
end
