defmodule UniboExPoc.Project.Changes.Task.ReopenCall12 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    module_ref = "Project"
    module = resolve_call_module(module_ref)
    if is_atom(module) and function_exported?(module, :sync_stage_to_project, 2) do
      apply(module, :sync_stage_to_project, [changeset, context])
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: #Project.sync_stage_to_project/2")
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
