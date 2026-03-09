defmodule UniboExPoc.Project.Validations.TaskDependency.NoCircularDependency do
  @moduledoc """
  校验规则: no_circular_dependency (entity: task_dependency)
  描述: 禁止循环依赖
  """

  use Ash.Resource.Validation

  @impl true
  def validate(changeset, _opts, _context) do
    # 循环依赖检测: 检查 parent_id 不会导致环
    parent_val = Ash.Changeset.get_attribute(changeset, :parent_id)
    record_id = changeset.data && changeset.data.id
    if parent_val == record_id do
      {:error, field: :parent_id, message: "禁止循环依赖"}
    else
      :ok
    end
  end
end
