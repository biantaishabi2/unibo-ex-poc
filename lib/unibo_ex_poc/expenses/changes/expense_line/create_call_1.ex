defmodule UniboV4.Expenses.Changes.ExpenseLine.CreateCall1 do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, context) do
    if function_exported?(Expenses, :relate_actor_employee, 2) do
      Expenses.relate_actor_employee(changeset, context)
    else
      Ash.Changeset.add_error(changeset, "call 目标不存在: Expenses.relate_actor_employee/2")
    end
  end
end
