defmodule UniboV4.Approvals do
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
    resource UniboV4.Approvals.ApprovalCategory
    resource UniboV4.Approvals.ApprovalCategory.Version
    resource UniboV4.Approvals.ApprovalRequest
    resource UniboV4.Approvals.ApprovalRequest.Version
    resource UniboV4.Approvals.Approver
    resource UniboV4.Approvals.Approver.Version
    resource UniboV4.Approvals.Party
  end
end
