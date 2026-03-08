defmodule UniboExPoc.Project.Validations.Task.NoCircularDependency do
  @moduledoc """
  校验规则: no_circular_dependency (entity: task)
  描述: 两个任务之间禁止循环依赖（A 阻塞 B 且 B 阻塞 A）
  """

  use Ash.Resource.Validation

  @impl true
  def validate(changeset, _opts, _context) do
    # 循环依赖检测: 检查 depend_on_ids 不会导致环
    parent_val = Ash.Changeset.get_attribute(changeset, :depend_on_ids)
    record_id = changeset.data && changeset.data.id
    if parent_val == record_id do
      {:error, field: :depend_on_ids, message: "两个任务之间禁止循环依赖（A 阻塞 B 且 B 阻塞 A）"}
    else
      :ok
    end
  end
end
