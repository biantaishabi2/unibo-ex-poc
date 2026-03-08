defmodule UniboV4.Manufacturing.Changes.ManufacturingOrder.ConfirmCall5 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(Manufacturing, :inherit_attribute, 2) do
      Manufacturing.inherit_attribute(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: Manufacturing.inherit_attribute/2")
    end
  end
end
