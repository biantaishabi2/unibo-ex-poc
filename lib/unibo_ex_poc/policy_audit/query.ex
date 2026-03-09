defmodule UniboExPoc.PolicyAudit.Query do
  @moduledoc """
  权限审计查询入口（按 user/resource/time-range/result 过滤）。
  """

  alias UniboExPoc.PolicyAudit.PolicyAuditLogger

  def search(filters \\ %{}), do: PolicyAuditLogger.query(filters)
end
