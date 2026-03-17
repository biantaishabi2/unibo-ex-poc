defmodule UniboExPoc.Sales.Changes.SalesOrder.CreateInvoicesCall15 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    module_ref = "UniboExPoc.Sales"
    module = resolve_call_module(module_ref)
    if is_atom(module) and function_exported?(module, :convert_to_refund, 2) do
      apply(module, :convert_to_refund, [changeset, context])
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: #UniboExPoc.Sales.convert_to_refund/2")
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
