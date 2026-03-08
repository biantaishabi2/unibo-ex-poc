defmodule UniboV4.Project.Changes.Project.UpdateCreateRelated7 do
  use Ash.Resource.Change

  alias UniboV4.Project.ProjectUpdate

  @impl true
  def change(changeset, _opts, context) do
    actor = Map.get(context, :actor)
    tenant = Map.get(context, :tenant) || Map.get(context, :tenant_id)
    opts = ash_call_opts(actor, tenant)
    params = %{}

    case Ash.create(Ash.Changeset.for_create(UniboV4.Project.ProjectUpdate, :create, params), opts) do
      {:ok, _created} -> changeset
      {:error, reason} ->
        Ash.Changeset.add_error(changeset, "create_related ProjectUpdate 失败: #{inspect(reason)}")
    end
  end

  defp ash_call_opts(actor, tenant) do
    [actor: actor]
    |> maybe_put_tenant(tenant)
  end

  defp maybe_put_tenant(opts, nil), do: opts
  defp maybe_put_tenant(opts, tenant), do: Keyword.put(opts, :tenant, tenant)
end
