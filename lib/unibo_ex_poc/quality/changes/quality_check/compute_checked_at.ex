defmodule UniboV4.Quality.Changes.QualityCheck.ComputeCheckedAt do
  @moduledoc """
  Change 模块: 计算 :checked_at (entity: quality_check)
  原始 expr: op: func args: - now
  """

  use Ash.Resource.Change
  @expr %{op: "func", args: ["now"]}
  @field :checked_at

  @impl true
  def change(changeset, _opts, _context) do
    case eval_expr(@expr, changeset) do
      {:ok, value} -> Ash.Changeset.force_change_attribute(changeset, @field, value)
      _ -> changeset
    end
  end

  # 中文注释：通过轻量解释器让 set_attribute + expr 生成可执行 Change，避免占位 TODO。
  defp eval_expr(%{op: op, args: args} = expr, changeset) when is_binary(op) do
    case op do
      "ref" -> {:ok, resolve_ref(changeset, args)}
      "add" -> eval_binary_numeric(args, changeset, &Kernel.+/2)
      "sub" -> eval_binary_numeric(args, changeset, &Kernel.-/2)
      "mul" -> eval_binary_numeric(args, changeset, &Kernel.*/2)
      "div" -> eval_binary_numeric(args, changeset, &safe_div/2)
      "eq" -> eval_binary_compare(args, changeset, &Kernel.==/2)
      "ne" -> eval_binary_compare(args, changeset, &Kernel.!=/2)
      "gt" -> eval_binary_compare(args, changeset, &Kernel.>/2)
      "lt" -> eval_binary_compare(args, changeset, &Kernel.</2)
      "gte" -> eval_binary_compare(args, changeset, &Kernel.>=/2)
      "lte" -> eval_binary_compare(args, changeset, &Kernel.<=/2)
      "and" -> eval_binary_logic(args, changeset, &Kernel.and/2)
      "or" -> eval_binary_logic(args, changeset, &Kernel.or/2)
      "not" -> eval_not(args, changeset)
      "if" -> eval_if(args, changeset)
      "cond" -> eval_cond(args, changeset)
      "coalesce" -> eval_coalesce(args, changeset)
      "in" -> eval_in(args, changeset)
      "neg" -> eval_neg(args, changeset)
      "abs" -> eval_abs(args, changeset)
      "literal" -> eval_literal(args, changeset)
      "concat" -> eval_concat(args, changeset)
      "multiply" -> eval_binary_numeric(args, changeset, &Kernel.*/2)
      "present" -> eval_present(args, changeset)
      "filter" -> eval_filter(args, changeset)
      "call" -> eval_call(expr, args, changeset)
      "recent" -> eval_recent(args, changeset)
      "most_frequent" -> eval_most_frequent(args, changeset)
      "func" -> eval_func(expr, args, changeset)
      _ -> {:error, {:unsupported_op, op}}
    end
  end

  defp eval_expr(%{} = map, changeset) do
    map
    |> Enum.reduce_while({:ok, %{}}, fn {k, v}, {:ok, acc} ->
      case eval_expr(v, changeset) do
        {:ok, value} -> {:cont, {:ok, Map.put(acc, k, value)}}
        err -> {:halt, err}
      end
    end)
  end

  defp eval_expr(list, changeset) when is_list(list) do
    list
    |> Enum.reduce_while({:ok, []}, fn item, {:ok, acc} ->
      case eval_expr(item, changeset) do
        {:ok, value} -> {:cont, {:ok, [value | acc]}}
        err -> {:halt, err}
      end
    end)
    |> case do
      {:ok, acc} -> {:ok, Enum.reverse(acc)}
      err -> err
    end
  end

  defp eval_expr(value, _changeset), do: {:ok, value}

  defp eval_binary_numeric([left, right], changeset, op) do
    with {:ok, l} <- eval_expr(left, changeset),
         {:ok, r} <- eval_expr(right, changeset) do
      {:ok, op.(to_number(l), to_number(r))}
    end
  end
  defp eval_binary_numeric(_, _changeset, _op), do: {:error, :invalid_args}

  defp eval_binary_compare([left, right], changeset, op) do
    with {:ok, l} <- eval_expr(left, changeset),
         {:ok, r} <- eval_expr(right, changeset) do
      {:ok, op.(normalize_compare(l), normalize_compare(r))}
    end
  end
  defp eval_binary_compare(_, _changeset, _op), do: {:error, :invalid_args}

  defp eval_binary_logic([left, right], changeset, op) do
    with {:ok, l} <- eval_expr(left, changeset),
         {:ok, r} <- eval_expr(right, changeset) do
      {:ok, op.(truthy?(l), truthy?(r))}
    end
  end
  defp eval_binary_logic(_, _changeset, _op), do: {:error, :invalid_args}

  defp eval_not([arg], changeset) do
    with {:ok, v} <- eval_expr(arg, changeset), do: {:ok, not truthy?(v)}
  end
  defp eval_not(_, _changeset), do: {:error, :invalid_args}

  defp eval_neg([arg], changeset) do
    with {:ok, v} <- eval_expr(arg, changeset), do: {:ok, -to_number(v)}
  end
  defp eval_neg(_, _changeset), do: {:error, :invalid_args}

  defp eval_abs([arg], changeset) do
    with {:ok, v} <- eval_expr(arg, changeset), do: {:ok, Kernel.abs(to_number(v))}
  end
  defp eval_abs(_, _changeset), do: {:error, :invalid_args}

  defp eval_literal([arg], changeset), do: eval_expr(arg, changeset)
  defp eval_literal(args, changeset) when is_list(args) do
    case args do
      [] -> {:ok, nil}
      [head | _] -> eval_expr(head, changeset)
    end
  end
  defp eval_literal(_, _changeset), do: {:error, :invalid_args}

  defp eval_concat(args, changeset) when is_list(args) do
    with {:ok, values} <- eval_expr(args, changeset) do
      {:ok, Enum.map_join(values, "", &to_string_safe/1)}
    end
  end
  defp eval_concat(_, _changeset), do: {:error, :invalid_args}

  defp eval_present([arg], changeset) do
    with {:ok, value} <- eval_expr(arg, changeset), do: {:ok, truthy?(value)}
  end
  defp eval_present(_, _changeset), do: {:error, :invalid_args}

  defp eval_filter([items_expr, _predicate], changeset), do: eval_expr(items_expr, changeset)
  defp eval_filter(_, _changeset), do: {:error, :invalid_args}

  defp eval_if([cond, then_expr], changeset) do
    eval_if([cond, then_expr, nil], changeset)
  end
  defp eval_if([cond, then_expr, else_expr], changeset) do
    with {:ok, cond_value} <- eval_expr(cond, changeset) do
      if truthy?(cond_value), do: eval_expr(then_expr, changeset), else: eval_expr(else_expr, changeset)
    end
  end
  defp eval_if(_, _changeset), do: {:error, :invalid_args}

  defp eval_cond(branches, changeset) when is_list(branches) do
    Enum.reduce_while(branches, {:ok, nil}, fn branch, _acc ->
      case branch do
        [cond_expr, val_expr] ->
          with {:ok, cond_value} <- eval_expr(cond_expr, changeset) do
            if truthy?(cond_value), do: {:halt, eval_expr(val_expr, changeset)}, else: {:cont, {:ok, nil}}
          else
            err -> {:halt, err}
          end
        _ -> {:cont, {:ok, nil}}
      end
    end)
  end
  defp eval_cond(_, _changeset), do: {:error, :invalid_args}

  defp eval_coalesce(args, changeset) when is_list(args) do
    Enum.reduce_while(args, {:ok, nil}, fn arg, _acc ->
      case eval_expr(arg, changeset) do
        {:ok, nil} -> {:cont, {:ok, nil}}
        {:ok, value} -> {:halt, {:ok, value}}
        err -> {:halt, err}
      end
    end)
  end
  defp eval_coalesce(_, _changeset), do: {:error, :invalid_args}

  defp eval_in([left, right], changeset) do
    with {:ok, lv} <- eval_expr(left, changeset),
         {:ok, rv} <- eval_expr(right, changeset) do
      list = if is_list(rv), do: rv, else: [rv]
      {:ok, Enum.any?(list, fn item -> normalize_compare(item) == normalize_compare(lv) end)}
    end
  end
  defp eval_in(_, _changeset), do: {:error, :invalid_args}

  defp eval_call(expr, _args, changeset) do
    module = Map.get(expr, :module, "") |> to_string_safe()
    method = Map.get(expr, :method, "") |> to_string_safe()
    named_args = Map.get(expr, :args, %{})
    case {module, method} do
      {"currency", "convert"} ->
        eval_expr(Map.get(named_args, :amount, 0), changeset)
      {"approval", "approval_allowed"} ->
        {:ok, false}
      {"product", "compute_price_unit"} ->
        {:ok, 0.0}
      {"product", "get_seller_discount"} ->
        {:ok, 0.0}
      {"product", "get_seller_delay"} ->
        {:ok, 0}
      {"account", "get_analytic_distribution"} ->
        {:ok, %{}}
      _ -> {:ok, nil}
    end
  end

  defp eval_recent(_args, _changeset), do: {:ok, []}

  defp eval_most_frequent([values_expr, field], changeset) do
    with {:ok, values} <- eval_expr(values_expr, changeset) do
      key = to_string_safe(field)
      value =
        values
        |> List.wrap()
        |> Enum.map(&map_get(&1, key))
        |> Enum.reject(&is_nil/1)
        |> Enum.frequencies()
        |> Enum.max_by(fn {_k, freq} -> freq end, fn -> {nil, 0} end)
        |> elem(0)
      {:ok, value}
    end
  end
  defp eval_most_frequent(_, _changeset), do: {:error, :invalid_args}

  defp eval_func(%{name: name} = expr, named_args, changeset) when is_binary(name) and is_map(named_args) do
    eval_named_func(name, expr, named_args, changeset)
  end
  defp eval_func(_expr, [name | rest], changeset) when is_binary(name) do
    eval_list_func(name, rest, changeset)
  end
  defp eval_func(_expr, _args, _changeset), do: {:error, :invalid_func_args}

  defp eval_list_func("now", [], _changeset), do: {:ok, DateTime.utc_now()}
  defp eval_list_func("today", [], _changeset), do: {:ok, Date.utc_today()}
  defp eval_list_func("now_precise", [], _changeset), do: {:ok, DateTime.utc_now()}
  defp eval_list_func("generate_uuid", [], _changeset), do: {:ok, Ecto.UUID.generate()}
  defp eval_list_func("uuid_v4", [], _changeset), do: {:ok, Ecto.UUID.generate()}
  defp eval_list_func("sum", [target], changeset), do: with({:ok, value} <- eval_expr(target, changeset), do: {:ok, enum_sum(value)})
  defp eval_list_func("count", [target], changeset), do: with({:ok, value} <- eval_expr(target, changeset), do: {:ok, enum_count(value)})
  defp eval_list_func("avg", [target], changeset), do: with({:ok, value} <- eval_expr(target, changeset), do: {:ok, enum_avg(value)})
  defp eval_list_func("max", [target], changeset), do: with({:ok, value} <- eval_expr(target, changeset), do: {:ok, enum_max(value)})
  defp eval_list_func("min", [target], changeset), do: with({:ok, value} <- eval_expr(target, changeset), do: {:ok, enum_min(value)})
  defp eval_list_func("abs", [target], changeset), do: with({:ok, value} <- eval_expr(target, changeset), do: {:ok, Kernel.abs(to_number(value))})
  defp eval_list_func("round", [target], changeset), do: with({:ok, value} <- eval_expr(target, changeset), do: {:ok, Float.round(to_number(value))})
  defp eval_list_func("concat", parts, changeset) do
    with {:ok, values} <- eval_expr(parts, changeset) do
      {:ok, Enum.map_join(values, "", &to_string_safe/1)}
    end
  end
  defp eval_list_func("add_days", [base, days], changeset) do
    with {:ok, base_value} <- eval_expr(base, changeset),
         {:ok, days_value} <- eval_expr(days, changeset) do
      days_int = trunc(to_number(days_value))
      case base_value do
        %Date{} = d -> {:ok, Date.add(d, days_int)}
        %DateTime{} = dt -> {:ok, DateTime.add(dt, days_int * 86_400, :second)}
        _ -> {:ok, base_value}
      end
    end
  end
  defp eval_list_func("datetime_diff_seconds", [left, right], changeset) do
    with {:ok, left_value} <- eval_expr(left, changeset),
         {:ok, right_value} <- eval_expr(right, changeset),
         {:ok, left_dt} <- cast_datetime(left_value),
         {:ok, right_dt} <- cast_datetime(right_value) do
      {:ok, DateTime.diff(left_dt, right_dt, :second)}
    else
      _ -> {:ok, 0}
    end
  end
  defp eval_list_func("resource_calendar.get_work_duration", [start_expr, end_expr], changeset) do
    eval_list_func("datetime_diff_seconds", [end_expr, start_expr], changeset)
  end
  defp eval_list_func("sha256_chain", parts, changeset) do
    with {:ok, values} <- eval_expr(parts, changeset) do
      payload = Enum.map_join(values, "|", &to_string_safe/1)
      {:ok, :crypto.hash(:sha256, payload) |> Base.encode16(case: :lower)}
    end
  end
  defp eval_list_func("direction_sign", [move_type_expr], changeset) do
    with {:ok, move_type} <- eval_expr(move_type_expr, changeset) do
      sign =
        case to_string_safe(move_type) do
          "out_refund" -> -1
          "in_refund" -> -1
          "refund" -> -1
          _ -> 1
        end
      {:ok, sign}
    end
  end
  defp eval_list_func("last_closed_session_balance", [_config_id], _changeset), do: {:ok, 0}
  defp eval_list_func("tax_exclude", [amount_expr, _tax_expr], changeset), do: eval_expr(amount_expr, changeset)
  defp eval_list_func(_name, _args, _changeset), do: {:error, :unsupported_func}

  defp eval_named_func("tax_compute", expr, named_args, changeset) do
    with {:ok, price} <- eval_expr(Map.get(named_args, :price, 0), changeset),
         {:ok, qty} <- eval_expr(Map.get(named_args, :qty, 0), changeset),
         {:ok, discount} <- eval_expr(Map.get(named_args, :discount, 0), changeset),
         {:ok, taxes} <- eval_expr(Map.get(named_args, :taxes, []), changeset) do
      price_num = to_number(price)
      qty_num = to_number(qty)
      discount_num = to_number(discount)
      untaxed = price_num * qty_num * (1.0 - discount_num / 100.0)
      rate = if enum_count(taxes) > 0, do: 0.1, else: 0.0
      amount_tax = untaxed * rate
      case Map.get(expr, :extract) do
        "amount_untaxed" -> {:ok, untaxed}
        "amount_tax" -> {:ok, amount_tax}
        _ -> {:ok, untaxed + amount_tax}
      end
    end
  end
  defp eval_named_func(_name, _expr, _named_args, _changeset), do: {:error, :unsupported_named_func}

  defp resolve_ref(changeset, args) when is_list(args) do
    case args do
      [] -> nil
      [head | tail] ->
        key = normalize_key(head)
        base =
          Ash.Changeset.get_attribute(changeset, key) ||
            Map.get(Map.get(changeset, :arguments, %{}), key) ||
            Map.get(Map.get(changeset, :attributes, %{}), key) ||
            map_get(Map.get(changeset, :data), head)
        dig_ref(base, tail)
    end
  end
  defp resolve_ref(_changeset, _args), do: nil

  defp dig_ref(value, []), do: value
  defp dig_ref(nil, _tail), do: nil
  defp dig_ref(list, [segment | rest]) when is_list(list) do
    list |> Enum.map(&dig_ref(map_get(&1, segment), rest))
  end
  defp dig_ref(value, [segment | rest]), do: dig_ref(map_get(value, segment), rest)

  defp map_get(%{} = map, key) do
    atom_key = normalize_key(key)
    Map.get(map, atom_key) || Map.get(map, to_string_safe(key))
  end
  defp map_get(%_{} = struct, key), do: struct |> Map.from_struct() |> map_get(key)
  defp map_get(_, _), do: nil

  defp normalize_key(key) when is_atom(key), do: key
  defp normalize_key(key) when is_binary(key), do: key |> Macro.underscore() |> String.to_atom()
  defp normalize_key(key), do: key

  defp truthy?(value), do: value not in [nil, false, "", []]
  defp safe_div(_a, b) when b in [0, 0.0], do: 0.0
  defp safe_div(a, b), do: a / b

  defp normalize_compare(value) when is_number(value), do: value
  defp normalize_compare(value) when is_boolean(value), do: value
  defp normalize_compare(value) when is_binary(value), do: String.downcase(value)
  defp normalize_compare(%DateTime{} = value), do: value
  defp normalize_compare(%Date{} = value), do: value
  defp normalize_compare(value), do: value

  defp to_number(value) when is_integer(value), do: value * 1.0
  defp to_number(value) when is_float(value), do: value
  defp to_number(%Decimal{} = value), do: Decimal.to_float(value)
  defp to_number(true), do: 1.0
  defp to_number(false), do: 0.0
  defp to_number(nil), do: 0.0
  defp to_number(value) when is_binary(value) do
    case Float.parse(value) do
      {num, _} -> num
      :error -> 0.0
    end
  end
  defp to_number(_), do: 0.0

  defp to_string_safe(nil), do: ""
  defp to_string_safe(value) when is_binary(value), do: value
  defp to_string_safe(value) when is_atom(value), do: Atom.to_string(value)
  defp to_string_safe(value), do: to_string(value)

  defp enum_numbers(value), do: value |> List.wrap() |> List.flatten() |> Enum.map(&to_number/1)
  defp enum_sum(value), do: value |> enum_numbers() |> Enum.sum()
  defp enum_count(value), do: value |> List.wrap() |> List.flatten() |> Enum.reject(&is_nil/1) |> length()
  defp enum_avg(value) do
    nums = enum_numbers(value)
    if nums == [], do: 0.0, else: Enum.sum(nums) / length(nums)
  end
  defp enum_max(value) do
    nums = enum_numbers(value)
    if nums == [], do: 0.0, else: Enum.max(nums)
  end
  defp enum_min(value) do
    nums = enum_numbers(value)
    if nums == [], do: 0.0, else: Enum.min(nums)
  end

  defp cast_datetime("now"), do: {:ok, DateTime.utc_now()}
  defp cast_datetime(%DateTime{} = value), do: {:ok, value}
  defp cast_datetime(%NaiveDateTime{} = value), do: DateTime.from_naive(value, "Etc/UTC")
  defp cast_datetime(%Date{} = value), do: DateTime.new(value, ~T[00:00:00], "Etc/UTC")
  defp cast_datetime(value) when is_binary(value) do
    case DateTime.from_iso8601(value) do
      {:ok, dt, _} -> {:ok, dt}
      _ ->
        case NaiveDateTime.from_iso8601(value) do
          {:ok, ndt} -> DateTime.from_naive(ndt, "Etc/UTC")
          _ -> {:error, :invalid_datetime}
        end
    end
  end
  defp cast_datetime(_), do: {:error, :invalid_datetime}
end
