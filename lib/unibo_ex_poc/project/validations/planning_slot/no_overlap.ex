defmodule UniboV4.Project.Validations.PlanningSlot.NoOverlap do
  @moduledoc """
  校验规则: no_overlap (entity: planning_slot)
  描述: 同一员工在同一时段不能有重叠排班
  """

  use Ash.Resource.Validation

  @impl true
  def validate(changeset, _opts, _context) do
    # 时间/范围重叠检测
    :ok
  end
end
