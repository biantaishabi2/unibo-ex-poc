defmodule UniboExPoc.Expenses.Changes.ExpenseLine.CreateCall1 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    module_ref = "Expenses"
    module = resolve_call_module(module_ref)
    if is_atom(module) and function_exported?(module, :relate_actor_employee, 2) do
      apply(module, :relate_actor_employee, [changeset, context])
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: #Expenses.relate_actor_employee/2")
    end
  end

  defp resolve_call_module(module) when is_atom(module), do: module
  defp resolve_call_module(module) when is_binary(module) do
    module
    |> String.trim()
    |> case do
      "" -> nil
      value ->
        value
        |> String.split(".", trim: true)
        |> Enum.map(fn seg -> if seg =~ ~r/^[A-Z]/, do: seg, else: Macro.camelize(seg) end)
        |> Module.concat()
    end
  rescue
    _ -> nil
  end
  defp resolve_call_module(_), do: nil
end
