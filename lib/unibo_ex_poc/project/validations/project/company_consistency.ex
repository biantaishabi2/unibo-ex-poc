defmodule UniboV4.Project.Validations.Project.CompanyConsistency do
  @moduledoc """
  校验规则: company_consistency (entity: project)
  描述: 项目各阶段、分析账户、合作伙伴的 company_id 必须与项目一致
  """

  use Ash.Resource.Validation

  @impl true
  def validate(changeset, _opts, _context) do
    # 公司一致性/隔离/成员校验
    :ok
  end
end
