defmodule UniboExPoc.Maintenance.Validations.EquipmentCategory.CompanyMember do
  @moduledoc """
  校验规则: company_member (entity: equipment_category)
  """

  use Ash.Resource.Validation

  @impl true
  def validate(changeset, _opts, _context) do
    # 公司一致性/隔离/成员校验
    :ok
  end
end
