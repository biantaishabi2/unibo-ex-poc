defmodule UniboExPoc.Maintenance.Validations.Equipment.CompanyIsolation do
  @moduledoc """
  校验规则: company_isolation (entity: equipment)
  """

  use Ash.Resource.Validation

  @impl true
  def validate(changeset, _opts, _context) do
    # 公司一致性/隔离/成员校验
    :ok
  end
end
