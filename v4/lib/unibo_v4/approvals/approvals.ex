defmodule UniboV4.Approvals do
  use Ash.Domain

  resources do
    resource UniboV4.Approvals.ApprovalCategory
    resource UniboV4.Approvals.ApprovalRequest
    resource UniboV4.Approvals.Approver
    resource UniboV4.Approvals.User
    resource UniboV4.Approvals.Company
  end
end
