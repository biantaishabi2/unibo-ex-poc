defmodule UniboExPoc.Approvals do
  use Ash.Domain,
    extensions: [AshGraphql.Domain]

  graphql do
    authorize? false
  end

  resources do
    resource UniboExPoc.Approvals.ApprovalCategory
    resource UniboExPoc.Approvals.ApprovalCategory.Version
    resource UniboExPoc.Approvals.ApprovalRequest
    resource UniboExPoc.Approvals.ApprovalRequest.Version
    resource UniboExPoc.Approvals.Approver
    resource UniboExPoc.Approvals.Approver.Version
    resource UniboExPoc.Approvals.Party
  end
end
