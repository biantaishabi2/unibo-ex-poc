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

    assert {:ok, %{page_data: %{selection: selection}}} =
             PageHostRuntime.load_page("shift_type_list", %{}, :graphql, EchoBackend)

    assert selection =~ "id code name"
    assert selection =~ "start_time: startTime"
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

  test "本地页面 sidecar 会补齐 expanded behavior 缺少的 backend 契约", %{tmp_dir: tmp_dir} do
    write_page!(tmp_dir, "shift_type_detail")

    write_behavior!(tmp_dir, "shift_type_detail", %{
      "backend" => %{
        "api_map" => %{
          "get" => "Scheduling.ShiftType.read"
        }
      }
    })

    app_behavior_dir = Path.join(File.cwd!(), "pages/scheduling/admin")
    File.mkdir_p!(app_behavior_dir)
    local_behavior_path = Path.join(app_behavior_dir, "shift_type_detail.behavior.v1.json")

    previous_local =
      if File.exists?(local_behavior_path) do
        {:ok, File.read!(local_behavior_path)}
      else
        :missing
      end

    on_exit(fn ->
      case previous_local do
        {:ok, content} -> File.write!(local_behavior_path, content)
        :missing -> File.rm_rf(local_behavior_path)
      end
    end)

    File.write!(
      local_behavior_path,
      Jason.encode!(%{
        "backend" => %{
          "params" => %{"accept" => ["id"]},
          "load" => %{"selection" => "id name code"}
        }
      })
    )

    contract = PageHostRuntime.page_contract("shift_type_detail")

    assert get_in(contract, ["backend", "api_map", "get"]) == "Scheduling.ShiftType.read"
    assert get_in(contract, ["backend", "params", "accept"]) == ["id"]
    assert get_in(contract, ["backend", "load", "selection"]) == "id name code"
  end

  test "load assigns 缺值时保留默认结构并应用 transform", %{tmp_dir: tmp_dir} do
    write_page!(tmp_dir, "solver_result")

    write_status_defaults!(tmp_dir, "solver_result", %{
      "run" => %{
        "status" => "",
        "engine_type" => "",
        "output_snapshot" => %{
          "summary" => %{
            "assignment_count" => "",
            "covered_requirement_count" => ""
          }
        }
      },
      "has_hard_violations" => true
    })

    write_behavior!(tmp_dir, "solver_result", %{
      "backend" => %{
        "load" => %{
          "assigns" => %{
            "run" => %{
              "from" => "record.last_solver_run",
              "transform" => "normalize_solver_run"
            },
            "has_hard_violations" => %{
              "from" => "record.last_solver_run.hard_violation_count",
              "transform" => "positive_count"
            }
          }
        }
      }
    })

    page_data =
      PageHostRuntime.default_assigns()
      |> Map.merge(%{
        record: %{
          last_solver_run: nil
        },
        _page_contract: PageHostRuntime.page_contract("solver_result")
      })
      |> PageHostRuntime.merge_backend_payload(%{"record" => %{"last_solver_run" => nil}}, %{})

    assert page_data.run.output_snapshot.summary.assignment_count == ""
    refute page_data.has_hard_violations
  end

  test "load assigns 支持字面量值和日期区间 transform", %{tmp_dir: tmp_dir} do
    write_page!(tmp_dir, "publish_preview")

    write_behavior!(tmp_dir, "publish_preview", %{
      "backend" => %{
        "load" => %{
          "assigns" => %{
            "changes" => %{"value" => []},
            "coverage_rate" => %{"value" => 0},
            "current_week_label" => %{
              "from" => "record",
              "transform" => "date_range_label"
            }
          }
        }
      }
    })

    page_data =
      PageHostRuntime.default_assigns()
      |> Map.merge(%{
        record: %{
          start_date: "2026-04-01",
          end_date: "2026-04-07"
        },
        _page_contract: PageHostRuntime.page_contract("publish_preview")
      })
      |> PageHostRuntime.merge_backend_payload(
        %{"record" => %{"start_date" => "2026-04-01", "end_date" => "2026-04-07"}},
        %{}
      )

    assert page_data.changes == []
    assert page_data.coverage_rate == 0
    assert page_data.current_week_label == "2026-04-01 ~ 2026-04-07"
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
